#!/bin/bash

set -e

SHOP_NAME="taroob-store"  # Your shop name from the URL
ACCESS_TOKEN=$(pass taroob/admin-api-token)  # Your private app access token
PRODUCT_ID="9418422223159"  # The product ID you want to track

# API endpoint
BASE_URL="https://${SHOP_NAME}.myshopify.com/admin/api/2023-10"

# Output file
OUTPUT_FILE="product_${PRODUCT_ID}_order_history_$(date +%Y%m%d_%H%M%S).csv"

# Function to verify product exists and get its details
verify_product() {
    echo "Verifying product ID: ${PRODUCT_ID}..."
    
    product_response=$(curl -s -H "X-Shopify-Access-Token: ${ACCESS_TOKEN}" \
        "${BASE_URL}/products/${PRODUCT_ID}.json")
    
    if echo "$product_response" | grep -q '"errors"'; then
        echo "Warning: Product ID ${PRODUCT_ID} might not exist or be accessible"
        echo "Error: $(echo "$product_response" | grep -o '"errors":[^}]*}')"
    else
        product_title=$(echo "$product_response" | jq -r '.product.title')
        echo "Product found: ${product_title}"
        
        # Show variant IDs
        echo "Product variants:"
        echo "$product_response" | jq -r '.product.variants[] | "Variant ID: \(.id), Title: \(.title)"'
    fi
    echo ""
}

# Function to make API calls with pagination
fetch_orders() {
    local next_url=""
    local page_count=1
    local total_orders_processed=0
    local orders_with_product=0
    
    echo "Fetching orders for product ID: ${PRODUCT_ID}..."
    
    # Initial URL
    local url="${BASE_URL}/orders.json?limit=250&status=any&fields=id,name,created_at,customer,line_items"
    
    while true; do
        echo "Processing page ${page_count}..."
        
        # Make API request and save headers to temp file
        response=$(curl -s -D headers.tmp -H "X-Shopify-Access-Token: ${ACCESS_TOKEN}" "$url")
        
        # Check if request was successful
        if echo "$response" | grep -q '"errors"'; then
            echo "Error: $(echo "$response" | grep -o '"errors":[^}]*}')"
            rm -f headers.tmp
            exit 1
        fi
        
        # Extract orders from response
        orders=$(echo "$response" | jq -r '.orders')
        
        # If no orders returned or empty array, break the loop
        if [ -z "$orders" ] || [ "$orders" = "null" ] || [ "$orders" = "[]" ]; then
            echo "No more orders found on page ${page_count}"
            break
        fi
        
        # Check if we actually got orders
        order_count=$(echo "$response" | jq -r '.orders | length')
        total_orders_processed=$((total_orders_processed + order_count))
        echo "Found ${order_count} orders on this page (Total processed: ${total_orders_processed})"
        
        if [ "$order_count" -eq 0 ]; then
            break
        fi
        
        # Debug: Show some product IDs from current batch (only on first few pages)
        if [ "$page_count" -le 3 ]; then
            echo "Sample product IDs from current batch:"
            echo "$response" | jq -r '.orders[0:3][] | .line_items[]?.product_id' | head -10
        fi
        
        # Process each order and filter for our product
        matching_orders=$(echo "$response" | jq -r --arg product_id "$PRODUCT_ID" '
        [.orders[] | 
        select(.line_items[]?.product_id == ($product_id | tonumber))] | length')
        
        if [ "$matching_orders" -gt 0 ]; then
            echo "Found ${matching_orders} orders with product ID ${PRODUCT_ID} on this page"
            orders_with_product=$((orders_with_product + matching_orders))
            
            echo "$response" | jq -r --arg product_id "$PRODUCT_ID" '
            .orders[] | 
            select(.line_items[]?.product_id == ($product_id | tonumber)) |
            {
                order_id: .id,
                order_name: .name,
                created_at: .created_at,
                customer_name: (if .customer then (.customer.first_name + " " + .customer.last_name) else "Guest Customer" end),
                customer_email: (.customer.email // "No email"),
                line_items: [.line_items[] | select(.product_id == ($product_id | tonumber)) | {quantity: .quantity, variant_title: .variant_title, price: .price}]
            }' >> temp_orders.json
        else
            echo "No orders found with product ID ${PRODUCT_ID} on this page"
        fi
        
        # Extract next page URL from Link header
        next_url=""
        if [ -f headers.tmp ]; then
            # Look for Link header with rel="next"
            link_header=$(grep -i "^Link:" headers.tmp | head -n 1)
            if [ ! -z "$link_header" ]; then
                # Extract URL with rel="next"
                next_url=$(echo "$link_header" | grep -o '<[^>]*>; rel="next"' | sed 's/<\([^>]*\)>; rel="next"/\1/')
            fi
        fi
        
        # Clean up temp headers file
        rm -f headers.tmp
        
        # If no next URL, we're done
        if [ -z "$next_url" ]; then
            break
        fi
        
        # Set URL for next iteration
        url="$next_url"
        ((page_count++))
        
        # Rate limiting - Shopify allows 2 requests per second
        sleep 0.5
    done
    
    echo ""
    echo "=== FETCH SUMMARY ==="
    echo "Total pages processed: ${page_count}"
    echo "Total orders processed: ${total_orders_processed}"
    echo "Orders containing product ID ${PRODUCT_ID}: ${orders_with_product}"
    echo ""
}

# Function to convert JSON to CSV
convert_to_csv() {
    echo "Converting data to CSV format..."
    
    # Create CSV header
    echo "Order ID,Order Name,Live Date,Customer Name,Customer Email,Quantity,Variant,Price" > "$OUTPUT_FILE"
    
    # Check if temp file exists and has content
    if [ -f temp_orders.json ] && [ -s temp_orders.json ]; then
        echo "Processing $(wc -l < temp_orders.json) lines from temp_orders.json"
        
        jq -r '
        .line_items[] as $item |
        [
            .order_id,
            .order_name,
            (.created_at | sub("\\.[0-9]+"; "") | strptime("%Y-%m-%dT%H:%M:%S%z") | strftime("%Y-%m-%d %H:%M:%S")),
            .customer_name,
            .customer_email,
            $item.quantity,
            ($item.variant_title // "Default"),
            $item.price
        ] | @csv' temp_orders.json >> "$OUTPUT_FILE"
        
        # Clean up temp file
        rm temp_orders.json
    else
        echo "No orders found for this product (temp_orders.json is empty or doesn't exist)."
        if [ -f temp_orders.json ]; then
            echo "temp_orders.json exists but is empty"
            rm temp_orders.json
        else
            echo "temp_orders.json was never created"
        fi
    fi
}

# Function to generate summary
generate_summary() {
    if [ -f "$OUTPUT_FILE" ]; then
        total_orders=$(tail -n +2 "$OUTPUT_FILE" | wc -l)
        unique_customers=$(tail -n +2 "$OUTPUT_FILE" | cut -d',' -f4 | sort -u | wc -l)
        total_quantity=$(tail -n +2 "$OUTPUT_FILE" | cut -d',' -f6 | awk '{sum += $1} END {print sum ? sum : 0}')
        
        echo ""
        echo "=== SUMMARY ==="
        echo "Product ID: $PRODUCT_ID"
        echo "Total Orders: $total_orders"
        echo "Unique Customers: $unique_customers"
        echo "Total Quantity Sold: $total_quantity"
        echo "Data saved to: $OUTPUT_FILE"
        echo ""
        
        if [ $total_orders -gt 0 ]; then
            echo "First 5 orders:"
            head -n 6 "$OUTPUT_FILE" | column -t -s','
        else
            echo "No matching orders found for this product."
            echo ""
            echo "Possible reasons:"
            echo "1. Product ID might be incorrect"
            echo "2. Product has no orders yet"
            echo "3. All orders are outside the date range"
            echo "4. Product ID format issue (string vs number)"
        fi
    fi
}

# Main execution
main() {
    # Check if required tools are installed
    if ! command -v curl &> /dev/null; then
        echo "Error: curl is required but not installed."
        exit 1
    fi
    
    if ! command -v jq &> /dev/null; then
        echo "Error: jq is required but not installed. Please install jq."
        exit 1
    fi
    
    # Validate configuration
    if [ "$ACCESS_TOKEN" = "your_access_token_here" ]; then
        echo "Error: Please set your Shopify access token in the script."
        echo "You need to create a private app in your Shopify admin and get the access token."
        exit 1
    fi
    
    echo "Starting Shopify product order history extraction..."
    echo "Shop: $SHOP_NAME"
    echo "Product ID: $PRODUCT_ID"
    echo ""
    
    # Verify product exists
    verify_product
    
    # Create temp file for JSON data
    > temp_orders.json
    
    # Fetch all orders
    fetch_orders
    
    # Convert to CSV
    convert_to_csv
    
    # Generate summary
    generate_summary
    
    echo "Script completed successfully!"
}

# Run the script
main

