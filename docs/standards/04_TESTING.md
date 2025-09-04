# 📚 Shared Development Standard
# Part of common standards library used by both Claude and Gemini

# Testing Standards

## Overview

This document establishes comprehensive testing standards for all development projects. Effective testing ensures code quality, reduces bugs, and provides confidence in deployments.

## Testing Philosophy

### Core Principles
- **Test Early, Test Often**: Write tests as you develop
- **Quality over Quantity**: Focus on meaningful tests over coverage metrics
- **Fast Feedback**: Tests should run quickly and provide clear results
- **Maintainable Tests**: Tests should be easy to understand and modify
- **Realistic Testing**: Test real scenarios, not just happy paths

### Testing Pyramid
```
    🔺 E2E Tests (Few)
   🔺🔺 Integration Tests (Some) 
  🔺🔺🔺 Unit Tests (Many)
```

- **Unit Tests (70%)**: Fast, isolated, focused on single functions/methods
- **Integration Tests (20%)**: Test component interactions
- **End-to-End Tests (10%)**: Full user workflows

## Testing Types and Standards

### Unit Tests
Test individual functions, methods, or classes in isolation.

**Characteristics:**
- Fast execution (< 1 second each)
- No external dependencies
- Focused on single responsibility
- Deterministic results

**Example (Python with pytest):**
```python
import pytest
from decimal import Decimal

# Example implementation for context
def calculate_tax(amount, tax_rate):
    """Calculate tax amount given principal and rate."""
    if amount < 0:
        raise ValueError("Amount cannot be negative")
    return amount * tax_rate

class TestCalculateTax:
    """Test cases for tax calculation function."""
    
    def test_calculate_standard_tax(self):
        """Test standard tax calculation with normal rates."""
        # Arrange
        amount = Decimal('100.00')
        tax_rate = Decimal('0.08')
        
        # Act
        result = calculate_tax(amount, tax_rate)
        
        # Assert
        assert result == Decimal('8.00')
    
    def test_calculate_tax_zero_amount(self):
        """Test tax calculation with zero amount."""
        result = calculate_tax(Decimal('0.00'), Decimal('0.08'))
        assert result == Decimal('0.00')
    
    def test_calculate_tax_zero_rate(self):
        """Test tax calculation with zero tax rate."""
        result = calculate_tax(Decimal('100.00'), Decimal('0.00'))
        assert result == Decimal('0.00')
    
    def test_calculate_tax_negative_amount_raises_error(self):
        """Test that negative amounts raise appropriate error."""
        with pytest.raises(ValueError, match="Amount cannot be negative"):
            calculate_tax(Decimal('-10.00'), Decimal('0.08'))
    
    @pytest.mark.parametrize("amount,rate,expected", [
        (Decimal('100.00'), Decimal('0.05'), Decimal('5.00')),
        (Decimal('250.00'), Decimal('0.10'), Decimal('25.00')),
        (Decimal('99.99'), Decimal('0.0825'), Decimal('8.24')),
    ])
    def test_calculate_tax_various_scenarios(self, amount, rate, expected):
        """Test tax calculation with various amount and rate combinations."""
        result = calculate_tax(amount, rate)
        assert result == expected
```

### Integration Tests
Test interactions between components, modules, or services.

**Example (Python with FastAPI):**
```python
import pytest
from fastapi.testclient import TestClient
from myapp.main import app
from myapp.database import get_test_db

@pytest.fixture
def client():
    """Create test client with test database."""
    app.dependency_overrides[get_db] = get_test_db
    with TestClient(app) as test_client:
        yield test_client
    app.dependency_overrides.clear()

class TestUserAPI:
    """Integration tests for user API endpoints."""
    
    def test_create_user_success(self, client):
        """Test successful user creation through API."""
        user_data = {
            "email": "test@example.com",
            "name": "Test User",
            "password": "securepassword123"
        }
        
        response = client.post("/api/users", json=user_data)
        
        assert response.status_code == 201
        data = response.json()
        assert data["email"] == user_data["email"]
        assert data["name"] == user_data["name"]
        assert "password" not in data  # Password should not be returned
        assert "id" in data
    
    def test_create_user_duplicate_email(self, client):
        """Test that duplicate emails are rejected."""
        user_data = {"email": "duplicate@example.com", "name": "User1"}
        
        # Create first user
        client.post("/api/users", json=user_data)
        
        # Attempt to create duplicate
        response = client.post("/api/users", json=user_data)
        
        assert response.status_code == 400
        assert "already exists" in response.json()["detail"]
```

### End-to-End (E2E) Tests
Test complete user workflows from start to finish.

**Example (JavaScript with Playwright):**
```javascript
import { test, expect } from '@playwright/test';

test.describe('User Registration Flow', () => {
  test('user can register and access dashboard', async ({ page }) => {
    // Navigate to registration page
    await page.goto('/register');
    
    // Fill registration form
    await page.fill('[data-testid="email-input"]', 'test@example.com');
    await page.fill('[data-testid="password-input"]', 'SecurePass123!');
    await page.fill('[data-testid="confirm-password-input"]', 'SecurePass123!');
    
    // Submit form
    await page.click('[data-testid="register-button"]');
    
    // Verify success message
    await expect(page.locator('[data-testid="success-message"]'))
      .toContainText('Registration successful');
    
    // Verify redirect to dashboard
    await expect(page).toHaveURL('/dashboard');
    
    // Verify user is logged in
    await expect(page.locator('[data-testid="user-menu"]'))
      .toContainText('test@example.com');
  });
});
```

## Test Organization and Structure

### Directory Structure
```
project/
├── src/
│   ├── app/
│   │   ├── models/
│   │   ├── services/
│   │   └── api/
│   └── tests/
│       ├── unit/
│       │   ├── test_models.py
│       │   ├── test_services.py
│       │   └── test_utils.py
│       ├── integration/
│       │   ├── test_api.py
│       │   └── test_database.py
│       ├── e2e/
│       │   ├── test_user_flows.py
│       │   └── test_admin_flows.py
│       ├── fixtures/
│       │   ├── conftest.py
│       │   └── test_data.py
│       └── helpers/
│           ├── factories.py
│           └── assertions.py
```

### Test Naming Conventions
- **Files**: `test_*.py` or `*_test.py`
- **Classes**: `TestClassName`
- **Methods**: `test_method_name_scenario_expected_result`

**Examples:**
```python
# ✅ Good test names
def test_calculate_tax_with_valid_inputs_returns_correct_amount()
def test_create_user_with_duplicate_email_raises_validation_error()
def test_login_with_invalid_credentials_returns_401()

# ❌ Poor test names
def test_tax()
def test_user_creation()
def test_login()
```

## Test Data Management

### Fixtures and Factories
Use fixtures for reusable test data and setup.

```python
# conftest.py
import pytest
from myapp.models import User
from myapp.database import get_test_session

@pytest.fixture
def db_session():
    """Provide database session for tests."""
    session = get_test_session()
    try:
        yield session
    finally:
        session.rollback()
        session.close()

@pytest.fixture
def sample_user(db_session):
    """Create a sample user for testing."""
    user = User(
        email="test@example.com",
        name="Test User",
        is_active=True
    )
    db_session.add(user)
    db_session.commit()
    return user

# factories.py
import factory
from myapp.models import User

class UserFactory(factory.Factory):
    class Meta:
        model = User
    
    email = factory.Sequence(lambda n: f"user{n}@example.com")
    name = factory.Faker('name')
    is_active = True
    created_at = factory.Faker('date_time')
```

### Test Data Isolation
- Each test should be independent
- Clean up data after each test
- Use transactions that can be rolled back
- Avoid shared mutable state

## Mocking and Stubbing

### When to Mock
- External API calls
- Database operations (in unit tests)
- File system operations
- Time-dependent operations
- Expensive computations

**Example (Python with unittest.mock):**
```python
import pytest
from unittest.mock import Mock, patch

# Example classes for context
class PaymentError(Exception):
    """Custom exception for payment processing errors."""
    pass

class PaymentService:
    """Service for processing payments."""
    def process_payment(self, amount, token):
        # This would normally call external_payment_api
        pass

class TestPaymentService:
    """Test payment service with mocked external dependencies."""
    
    @patch('myapp.services.external_payment_api')
    def test_process_payment_success(self, mock_api):
        """Test successful payment processing."""
        # Arrange
        mock_api.charge.return_value = {
            'id': 'txn_123',
            'status': 'succeeded',
            'amount': 1000
        }
        
        service = PaymentService()
        
        # Act
        result = service.process_payment(amount=10.00, token='card_token')
        
        # Assert
        assert result.transaction_id == 'txn_123'
        assert result.status == 'succeeded'
        mock_api.charge.assert_called_once_with(
            amount=1000,  # Amount in cents
            source='card_token'
        )
    
    @patch('myapp.services.external_payment_api')
    def test_process_payment_api_failure(self, mock_api):
        """Test payment processing when API fails."""
        # Arrange
        mock_api.charge.side_effect = Exception("API Error")
        service = PaymentService()
        
        # Act & Assert
        with pytest.raises(PaymentError, match="Payment processing failed"):
            service.process_payment(amount=10.00, token='card_token')
```

## Test Configuration

### pytest Configuration (pytest.ini)
```ini
[pytest]
testpaths = tests
python_files = test_*.py *_test.py
python_classes = Test*
python_functions = test_*
addopts = 
    --verbose
    --tb=short
    --strict-markers
    --disable-warnings
    --cov=src
    --cov-report=html
    --cov-report=term-missing
    --cov-fail-under=80
markers =
    slow: marks tests as slow (deselect with '-m "not slow"')
    integration: marks tests as integration tests
    unit: marks tests as unit tests
    e2e: marks tests as end-to-end tests
    smoke: marks tests as smoke tests
filterwarnings =
    ignore::DeprecationWarning:pytest.*
    ignore::PendingDeprecationWarning
```

### JavaScript Testing (Jest)
```javascript
// jest.config.js
module.exports = {
  testEnvironment: 'node',
  roots: ['<rootDir>/src', '<rootDir>/tests'],
  testMatch: [
    '**/__tests__/**/*.test.{js,ts}',
    '**/?(*.)+(spec|test).{js,ts}'
  ],
  collectCoverageFrom: [
    'src/**/*.{js,ts}',
    '!src/**/*.d.ts',
    '!src/**/*.test.{js,ts}',
  ],
  coverageThreshold: {
    global: {
      branches: 80,
      functions: 80,
      lines: 80,
      statements: 80
    }
  },
  setupFilesAfterEnv: ['<rootDir>/tests/setup.js'],
  testTimeout: 10000
};
```

## Performance Testing

### Load Testing Example
```python
import pytest
import time
from concurrent.futures import ThreadPoolExecutor

# Example service for context
class UserService:
    """Service for managing users."""
    def create_user(self, email, name):
        # This would normally create a user in the database
        pass

class TestPerformance:
    """Performance tests for critical operations."""
    
    def test_user_creation_performance(self):
        """Test that user creation completes within acceptable time."""
        service = UserService()
        start_time = time.time()
        
        # Create user
        user = service.create_user(
            email="perf@example.com",
            name="Performance Test"
        )
        
        end_time = time.time()
        duration = end_time - start_time
        
        # Should complete within 100ms
        assert duration < 0.1, f"User creation took {duration:.3f}s"
        assert user.id is not None
    
    def test_concurrent_user_operations(self):
        """Test system under concurrent load."""
        service = UserService()
        
        def create_user(index):
            return service.create_user(
                email=f"user{index}@example.com",
                name=f"User {index}"
            )
        
        start_time = time.time()
        
        # Create 10 users concurrently
        with ThreadPoolExecutor(max_workers=10) as executor:
            futures = [executor.submit(create_user, i) for i in range(10)]
            results = [future.result() for future in futures]
        
        end_time = time.time()
        duration = end_time - start_time
        
        # All operations should complete
        assert len(results) == 10
        assert all(user.id is not None for user in results)
        
        # Should complete within 2 seconds
        assert duration < 2.0, f"Concurrent operations took {duration:.3f}s"
```

## Test Quality and Best Practices

### Test Quality Checklist
- [ ] **Clear and descriptive test names**
- [ ] **One assertion per test concept**
- [ ] **Arrange-Act-Assert structure**
- [ ] **Independent and isolated tests**
- [ ] **Fast execution**
- [ ] **Deterministic results**
- [ ] **Meaningful error messages**
- [ ] **Proper cleanup**

### Assertion Best Practices
```python

# Example function for context
def create_user(email, name):
    """Create a user with given email and name."""
    pass


# ✅ Good assertions
def test_user_creation_sets_correct_attributes():
    user = create_user("test@example.com", "Test User")
    
    assert user.email == "test@example.com"
    assert user.name == "Test User"
    assert user.is_active is True
    assert user.created_at is not None

# ❌ Poor assertions
def test_user_creation():
    user = create_user("test@example.com", "Test User")
    assert user  # Too vague
    assert len(user.__dict__) > 0  # Tests implementation details
```

### Error Testing
```python

# Example classes for context
class Calculator:
    """Simple calculator class."""
    def divide(self, a, b):
        if b == 0:
            raise ZeroDivisionError("Cannot divide by zero")
        return a / b

class ValidationError(Exception):
    """Custom validation exception."""
    pass

def validate_email(email):
    """Validate email format."""
    if "@" not in email:
        raise ValidationError("Please provide a valid email address")
    return True


# Test specific error conditions
def test_divide_by_zero_raises_appropriate_error():
    calculator = Calculator()
    
    with pytest.raises(ZeroDivisionError, match="Cannot divide by zero"):
        calculator.divide(10, 0)

# Test error messages
def test_invalid_email_provides_helpful_message():
    with pytest.raises(ValidationError) as exc_info:
        validate_email("invalid-email")
    
    assert "valid email address" in str(exc_info.value)
```

## Continuous Integration

### Test Pipeline Configuration
```yaml
# .github/workflows/test.yml
name: Test Suite

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    
    strategy:
      matrix:
        python-version: [3.9, 3.10, 3.11]
    
    steps:
    - uses: actions/checkout@v4
    
    - name: Set up Python ${{ matrix.python-version }}
      uses: actions/setup-python@v5
      with:
        python-version: ${{ matrix.python-version }}
    
    - name: Install dependencies
      run: |
        python -m pip install --upgrade pip
        pip install -r requirements-test.txt
    
    - name: Run unit tests
      run: pytest tests/unit/ -v --cov=src
    
    - name: Run integration tests
      run: pytest tests/integration/ -v
    
    - name: Run linting
      run: |
        flake8 src tests
        black --check src tests
        mypy src
    
    - name: Upload coverage
      uses: codecov/codecov-action@v4
      with:
        file: ./coverage.xml
```

## Test Maintenance

### Regular Maintenance Tasks
- Review and update test data
- Remove obsolete tests
- Refactor duplicate test code
- Update assertions for new requirements
- Monitor test execution times
- Review test coverage reports

### Test Debt Management
- Identify slow or flaky tests
- Prioritize test improvements
- Set test quality goals
- Track test maintenance metrics
- Regular test suite cleanup

## Coverage and Metrics

### Coverage Guidelines
- **Aim for 80-90% line coverage**
- **Focus on critical business logic**
- **100% coverage is not always necessary**
- **Quality over quantity**

### Important Metrics
- Test execution time
- Test failure rate
- Code coverage percentage
- Flaky test frequency
- Bug detection rate

## Common Testing Patterns

### Builder Pattern for Test Data
```python

# Example User class for context
class User:
    """User model."""
    def __init__(self, email, name, is_active=True, created_at=None):
        self.email = email
        self.name = name
        self.is_active = is_active
        self.created_at = created_at


class UserTestBuilder:
    """Builder for creating test users with custom attributes."""
    
    def __init__(self):
        self.email = "test@example.com"
        self.name = "Test User"
        self.is_active = True
        self.created_at = None
    
    def with_email(self, email):
        self.email = email
        return self
    
    def with_name(self, name):
        self.name = name
        return self
    
    def inactive(self):
        self.is_active = False
        return self
    
    def with_created_at(self, created_at):
        self.created_at = created_at
        return self
    
    def build(self):
        return User(
            email=self.email,
            name=self.name,
            is_active=self.is_active,
            created_at=self.created_at
        )

# Usage
def test_inactive_user():
    user = (UserTestBuilder()
            .with_email("inactive@example.com")
            .inactive()
            .build())
    
    assert user.is_active is False
```

### Page Object Pattern (E2E Tests)
```python
class LoginPage:
    """Page object for login page interactions."""
    
    def __init__(self, page):
        self.page = page
        self.email_input = '[data-testid="email-input"]'
        self.password_input = '[data-testid="password-input"]'
        self.login_button = '[data-testid="login-button"]'
        self.error_message = '[data-testid="error-message"]'
    
    async def goto(self):
        await self.page.goto('/login')
    
    async def login(self, email, password):
        await self.page.fill(self.email_input, email)
        await self.page.fill(self.password_input, password)
        await self.page.click(self.login_button)
    
    async def get_error_message(self):
        return await self.page.locator(self.error_message).text_content()

# Usage in tests
async def test_login_with_invalid_credentials(page):
    login_page = LoginPage(page)
    await login_page.goto()
    await login_page.login("invalid@example.com", "wrongpassword")
    
    error = await login_page.get_error_message()
    assert "Invalid credentials" in error
```

## Testing Best Practices Summary

### Do This ✅
- Write tests before or during development (TDD/BDD)
- Use descriptive test names that explain the scenario
- Follow the Arrange-Act-Assert pattern
- Keep tests simple and focused
- Test both happy paths and error conditions
- Use appropriate mocking for external dependencies
- Maintain test data isolation
- Regular test suite maintenance

### Avoid This ❌
- Writing tests only after development is complete
- Testing implementation details instead of behavior
- Creating overly complex test setups
- Sharing state between tests
- Ignoring flaky or slow tests
- Achieving coverage without meaningful assertions
- Testing everything through the UI
- Neglecting test maintenance

---

*Good tests are your safety net. Invest in them, and they'll catch you when you fall.*