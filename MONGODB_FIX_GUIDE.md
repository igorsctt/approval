# MongoDB Database Connection Fix - Action Plan

## Problem
Your Rails app on Render is connecting to the `test` database instead of `kaefer_approval`.

## Root Cause
The `MONGODB_URI` environment variable in Render is likely pointing to the wrong database name or not set correctly.

## Solution Steps

### 1. Update Render Environment Variable
In your Render dashboard:
1. Go to your Rails service
2. Navigate to Environment tab
3. Find or add `MONGODB_URI` variable
4. Set it to: `mongodb+srv://sousaigor:zRFWDklR6NiE3UOI@cluster0.qjyol.mongodb.net/kaefer_approval?retryWrites=true&w=majority&appName=Cluster0`
5. Save and redeploy

### 2. Verify Database Name Extraction
The database name should be extracted as `kaefer_approval` from the URI.

Current URI format: `mongodb+srv://user:password@cluster/DATABASE_NAME?options`
Your database name: `kaefer_approval`

### 3. Test Endpoints After Update
After updating the environment variable and redeploying:

1. Test environment check: `GET /check_env`
   - Should show `database_name: "kaefer_approval"`

2. Test authentication: `POST /debug_auth`
   - Should connect to the correct database
   - Should return user count from kaefer_approval database

## Important Notes

- Make sure to redeploy after changing environment variables
- The production configuration in `config/mongoid.yml` correctly uses `ENV['MONGODB_URI']`
- No code changes are needed, only environment variable update

## Verification
After making these changes, the `/check_env` endpoint should return:
```json
{
  "mongodb_uri": "mongodb+srv://sousaigor:zRFWDklR6NiE3UOI@cluster0.qjyol.mongodb.net/kaefer_approval?retryWrites=true&w=majority&appName=Cluster0",
  "rails_env": "production",
  "database_name": "kaefer_approval"
}
```
