-- Show all users
SELECT 
  id,
  username,
  name,
  CASE role 
    WHEN 0 THEN 'Admin'
    WHEN 1 THEN 'Manager'
    WHEN 2 THEN 'Shopkeeper'
    ELSE 'Unknown'
  END as role_name,
  shopid,
  isactive,
  createddate
FROM users
ORDER BY createddate DESC;
