
```bash
brew install postgresql
brew services start postgresql
psql postgres -c "CREATE ROLE postgres WITH LOGIN SUPERUSER PASSWORD 'kds007kds';"
psql -U postgres
```

