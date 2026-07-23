# DeepSight Framework Guide — Django

## Detection
- File patterns: settings.py, urls.py, models.py, views.py, manage.py
- requirements.txt: Django, djangorestframework, django-cors-headers

## Key Vulnerabilities

### DEBUG=True in Production
Flag Critical. Set DEBUG = False and configure proper error views.

### SQL Injection via Raw SQL
Flag Critical. Use parameterized queries with %s placeholders.

### Mass Assignment (DRF)
Flag Critical. Define explicit fields and read_only_fields in serializers.

### Missing Permission Classes
Flag High. Add permission_classes = [IsAuthenticated] on every view.

### N+1 Query via ORM
Flag High. Use select_related for FK and prefetch_related for M2M.

### SECRET_KEY Hardcoded
Flag Critical. Read from environment variable.

### Missing CSRF on POST Endpoints
Flag High. Use proper CSRF protection or tokens.

### Fat Models (God Object)
Flag High. Extract business logic to service classes.

## DRF Rules
- Never use fields = '__all__' - always explicit fields list
- ViewSet + Router pattern over function-based views
- permission_classes required on every view
- throttle_classes on public API endpoints
- Use PageNumberPagination for paginated lists
- Use django-filter for complex query filtering
