# 📚 Shared Development Standard
# Part of common standards library used by both Claude and Gemini

# Security Guidelines

## =� Core Security Principles

Security is a top priority in all development work. These guidelines must be followed across all projects.

## Secrets and Credentials Management

###  Do This
- Use environment variables for all secrets and API keys
- Store secrets in secure credential management systems
- Use `.env` files for local development (never commit them)
- Rotate credentials regularly
- Use different credentials for different environments

### L Never Do This
- Never commit secrets, API keys, or passwords to version control
- Never hardcode credentials in source code
- Never share credentials in plain text (Slack, email, etc.)
- Never use production credentials in development/testing

### Environment Variables Pattern
```bash
# .env (local development - never commit)
DATABASE_URL="postgresql://user:pass@localhost:5432/dbname"
API_SECRET_KEY="your-secret-key-here"
ANTHROPIC_API_KEY="sk-ant-api03-..."

# .env.example (commit this template)
DATABASE_URL="postgresql://user:pass@localhost:5432/dbname"
API_SECRET_KEY="your-secret-key-here"
ANTHROPIC_API_KEY="sk-ant-api03-..."
```

## Input Validation and Sanitization

### API Endpoints
- Validate all input parameters (type, length, format)
- Use parameterized queries for database operations
- Sanitize user input before processing
- Implement rate limiting on public endpoints
- Use proper HTTP status codes

### Example: Secure FastAPI Endpoint
```python
from pydantic import BaseModel, validator
from fastapi import HTTPException, Depends

class UserInput(BaseModel):
    email: str
    name: str

    @validator('email')
    def validate_email(cls, v):
        if '@' not in v or len(v) > 254:
            raise ValueError('Invalid email format')
        return v.lower().strip()

@app.post("/api/users")
async def create_user(user_data: UserInput, current_user=Depends(get_current_user)):
    # Input is automatically validated by Pydantic
    # Use parameterized queries
    result = await database.execute(
        "INSERT INTO users (email, name) VALUES ($1, $2)",
        user_data.email, user_data.name
    )
    return {"status": "created"}
```

## Authentication and Authorization

### JWT Token Security
- Use strong, randomly generated secret keys
- Set appropriate token expiration times
- Implement token refresh mechanisms
- Validate tokens on every protected endpoint
- Store tokens securely on client side

### Session Management
```python
# Secure JWT configuration
JWT_SECRET_KEY = os.getenv("JWT_SECRET_KEY")  # From environment
JWT_ALGORITHM = "HS256"
JWT_EXPIRATION_HOURS = 24

# Always validate tokens
async def get_current_user(token: str = Depends(oauth2_scheme)):
    try:
        payload = jwt.decode(token, JWT_SECRET_KEY, algorithms=[JWT_ALGORITHM])
        user_id = payload.get("sub")
        if user_id is None:
            raise HTTPException(status_code=401, detail="Invalid token")
        return await get_user_by_id(user_id)
    except JWTError:
        raise HTTPException(status_code=401, detail="Invalid token")
```

## Database Security

### Query Safety
- Always use parameterized queries
- Never construct SQL with string concatenation
- Use ORM/query builders when possible
- Implement proper error handling without exposing internals

### Safe Database Operations
```python
#  SAFE - Parameterized query
async def get_user_by_email(email: str):
    return await database.fetch_one(
        "SELECT * FROM users WHERE email = $1", email
    )

# L DANGEROUS - SQL injection risk
async def get_user_by_email_unsafe(email: str):
    query = f"SELECT * FROM users WHERE email = '{email}'"
    return await database.fetch_one(query)
```

## HTTPS and Transport Security

### Production Requirements
- Always use HTTPS in production
- Implement HSTS headers
- Use secure cookie flags
- Validate SSL certificates

### FastAPI Security Headers
```python
from fastapi.middleware.cors import CORSMiddleware
from fastapi.middleware.httpsredirect import HTTPSRedirectMiddleware

# Force HTTPS in production
if ENVIRONMENT == "production":
    app.add_middleware(HTTPSRedirectMiddleware)

# Secure CORS configuration
app.add_middleware(
    CORSMiddleware,
    allow_origins=["https://yourdomain.com"],  # Specific origins
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "DELETE"],
    allow_headers=["Authorization", "Content-Type"],
)
```

## Error Handling and Logging

### Security-Aware Error Handling
- Never expose internal system details in error messages
- Log security events appropriately
- Implement proper exception handling
- Use different error messages for different audiences

### Safe Error Handling
```python
#  SAFE - Generic error message for users
@app.exception_handler(Exception)
async def generic_exception_handler(request: Request, exc: Exception):
    # Log detailed error for developers
    logger.error(f"Unexpected error: {str(exc)}", exc_info=True)

    # Return generic message to users
    return JSONResponse(
        status_code=500,
        content={"error": "An internal error occurred"}
    )

#  SAFE - Specific handling for known errors
@app.exception_handler(ValidationError)
async def validation_exception_handler(request: Request, exc: ValidationError):
    return JSONResponse(
        status_code=400,
        content={"error": "Invalid input data", "details": exc.errors()}
    )
```

## Frontend Security

### React Security Best Practices
- Sanitize user input before rendering
- Use HTTPS for all API calls
- Store tokens securely (httpOnly cookies preferred)
- Implement proper CSRF protection
- Validate data received from APIs

### Secure API Calls
```javascript
//  SECURE - Proper error handling and validation
const fetchUserData = async () => {
  try {
    const response = await fetch('/api/user', {
      method: 'GET',
      headers: {
        'Authorization': `Bearer ${getAuthToken()}`,
        'Content-Type': 'application/json',
      },
    });

    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }

    const data = await response.json();

    // Validate received data
    if (!data || typeof data.email !== 'string') {
      throw new Error('Invalid response format');
    }

    return data;
  } catch (error) {
    console.error('Failed to fetch user data:', error);
    // Handle error appropriately - don't expose internals
    throw new Error('Failed to load user information');
  }
};
```

## Development Environment Security

### Local Development
- Use different credentials for dev/staging/production
- Keep `.env` files out of version control
- Regularly update dependencies
- Use security scanners in CI/CD

### Git Repository Security
```bash
# .gitignore - Always include these
.env
.env.local
.env.*.local
*.key
*.pem
config/secrets.json
credentials.json
```

## Dependency Management

### Package Security
- Regularly audit dependencies for vulnerabilities
- Use locked dependency versions
- Update dependencies on a regular schedule
- Scan for known security issues

### Example Security Commands
```bash
# Python security audit
pip-audit

# Node.js security audit
npm audit
npm audit fix

# Check for outdated packages
pip list --outdated
npm outdated
```

## Security Testing

### Regular Security Checks
- Run security linters (bandit for Python, ESLint security rules)
- Perform dependency vulnerability scans
- Test authentication and authorization flows
- Validate input sanitization

### Example Security Test
```python
# Test for SQL injection protection
def test_sql_injection_protection():
    malicious_input = "'; DROP TABLE users; --"

    # This should not cause any database issues
    result = get_user_by_email(malicious_input)

    # Should return None/empty, not cause an error
    assert result is None
```

## Incident Response

### When Security Issues Are Found
1. **Immediate**: Assess the scope and impact
2. **Contain**: Prevent further exposure
3. **Fix**: Apply security patches
4. **Document**: Record what happened and how it was fixed
5. **Learn**: Update processes to prevent recurrence

### Emergency Contacts
- Security team lead
- DevOps/Infrastructure team
- Legal/Compliance team (if data exposure)

---

## Security Checklist

### Before Every Release
- [ ] All secrets moved to environment variables
- [ ] Input validation implemented on all endpoints
- [ ] SQL injection protection verified
- [ ] Authentication/authorization tested
- [ ] HTTPS enforced in production
- [ ] Error handling doesn't expose internals
- [ ] Dependencies scanned for vulnerabilities
- [ ] Security headers configured

### Regular Maintenance
- [ ] Rotate credentials quarterly
- [ ] Update dependencies monthly
- [ ] Review access permissions
- [ ] Audit logs for suspicious activity
- [ ] Test backup and recovery procedures

---

*Security is everyone's responsibility. When in doubt, ask for a security review.*
