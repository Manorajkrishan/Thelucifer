# 🔧 Fix: Invalid Credentials Login Error

## 🎯 **Problem**

Getting "Invalid credentials" when trying to login. This happens because:

1. **No Users in Database:** After switching to MySQL, the users table is empty
2. **Seeder Didn't Run:** UserSeeder wasn't executed
3. **Password Mismatch:** Password hash might be incorrect

---

## ✅ **Solution**

### **Quick Fix: Create Admin User**

Run this command to create the admin user:

```powershell
cd backend\api
C:\php81\php.exe artisan tinker
```

Then paste this code:
```php
$user = App\Models\User::firstOrCreate(
    ['email' => 'admin@sentinelai.com'],
    [
        'name' => 'Admin',
        'password' => Illuminate\Support\Facades\Hash::make('admin123')
    ]
);

if (!$user->wasRecentlyCreated) {
    $user->password = Illuminate\Support\Facades\Hash::make('admin123');
    $user->save();
    echo "Updated admin user\n";
} else {
    echo "Created admin user\n";
}

echo "Email: " . $user->email . "\n";
```

Or use the script:
```powershell
.\CREATE-ADMIN-USER.ps1
```

---

## 🔍 **Why This Happened**

When we switched from SQLite to MySQL:
- Old users were in SQLite database
- MySQL database is fresh (0 users)
- No users = can't login

---

## ✅ **What Was Fixed**

1. **User Creation Script:**
   - `CREATE-ADMIN-USER.ps1` - Creates admin user
   - Verifies user creation
   - Tests login

2. **User Seeder:**
   - `UserSeeder.php` exists
   - Can be run manually if needed

---

## 🚀 **Steps to Fix**

### **Option 1: Use Script (Easiest)**

```powershell
.\CREATE-ADMIN-USER.ps1
```

### **Option 2: Manual Creation**

```powershell
cd backend\api
C:\php81\php.exe artisan tinker
```

```php
use App\Models\User;
use Illuminate\Support\Facades\Hash;

User::create([
    'name' => 'Admin',
    'email' => 'admin@sentinelai.com',
    'password' => Hash::make('admin123'),
]);
```

### **Option 3: Run Seeder**

```powershell
cd backend\api
C:\php81\php.exe artisan db:seed --class=UserSeeder
```

---

## ✅ **Verify**

After creating the user:

1. **Check User Exists:**
   ```powershell
   cd backend\api
   C:\php81\php.exe artisan tinker
   ```
   ```php
   App\Models\User::count()
   App\Models\User::where('email', 'admin@sentinelai.com')->first()
   ```

2. **Test Login:**
   - Go to: http://localhost:5173/login
   - Email: `admin@sentinelai.com`
   - Password: `admin123`
   - Should login successfully!

---

## 💡 **Default Credentials**

- **Email:** `admin@sentinelai.com`
- **Password:** `admin123`

---

## 🐛 **If Still Not Working**

1. **Check Database:**
   ```php
   App\Models\User::all()
   ```

2. **Check Password Hash:**
   ```php
   $user = App\Models\User::where('email', 'admin@sentinelai.com')->first();
   Hash::check('admin123', $user->password)
   ```

3. **Recreate User:**
   ```php
   $user = App\Models\User::where('email', 'admin@sentinelai.com')->first();
   if ($user) $user->delete();
   // Then create again
   ```

---

**After creating the user, you should be able to login!** 🚀
