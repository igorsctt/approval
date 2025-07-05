#!/bin/bash
# Test with different database names

echo "Testing with 'test' database..."
MONGODB_TEST="mongodb+srv://kaefer_user:KaeferApproval2024!@kaefer-approval.i3rewq4.mongodb.net/test?retryWrites=true&w=majority"

echo "Use this in Render environment variables:"
echo "MONGODB_URI=$MONGODB_TEST"

echo ""
echo "Or testing with admin database..."
MONGODB_ADMIN="mongodb+srv://kaefer_user:KaeferApproval2024!@kaefer-approval.i3rewq4.mongodb.net/?retryWrites=true&w=majority"
echo "MONGODB_URI=$MONGODB_ADMIN"
