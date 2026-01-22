# 🎛️ Admin Dashboard Guide - SentinelAI X

## 📋 **Overview**

The **Admin Dashboard** is a Vue.js-based administrative interface for managing the SentinelAI X cybersecurity platform. It provides a professional, secure interface for security administrators to monitor threats, manage documents, handle incidents, and configure the system.

**Access URL:** http://localhost:5173  
**Technology:** Vue.js 3 + Pinia + Vue Router + Tailwind CSS

---

## 🔐 **Authentication**

### **Login Page** (`/login`)
- **Purpose:** Secure authentication for admin users
- **Features:**
  - Email/password login
  - Token-based authentication (Laravel Sanctum)
  - Automatic token storage in localStorage
  - Redirects to dashboard after successful login
  - Error handling for invalid credentials

**Default Credentials:**
- Email: `admin@sentinelai.com`
- Password: `admin123`

---

## 🏠 **Dashboard** (`/`)

### **Main Dashboard Page**
**Purpose:** Overview of system status and recent activity

**Features:**
1. **Statistics Cards:**
   - **Total Threats:** Count of all detected threats
   - **Active Threats:** Currently detected threats (red indicator)
   - **Last 24h:** Threats detected in the last 24 hours (orange indicator)
   - **Resolved:** Successfully resolved threats (green indicator)

2. **Recent Threats Table:**
   - Lists the 10 most recent threats
   - Shows: Type, Severity, Status, Detection Date
   - Clickable threat links to view details
   - Color-coded severity (Red: 8-10, Orange: 5-7, Yellow: 1-4)
   - Status badges (Detected, Analyzing, Mitigated, Resolved)

**Data Source:** Laravel API (`/api/threats/statistics` and `/api/threats`)

---

## 🛡️ **Threats Management** (`/threats`)

### **Threats List Page**
**Purpose:** View and manage all cybersecurity threats

**Features:**
1. **Threats Table:**
   - **ID:** Unique threat identifier
   - **Type:** Threat category (Malware, DDoS, SQL Injection, etc.)
   - **Severity:** Risk level (1-10 scale)
   - **Status:** Current state (detected, analyzing, mitigated, resolved)
   - **Source IP:** Attacker's IP address
   - **Detected:** Timestamp of detection
   - **Actions:** View details link

2. **Actions:**
   - "New Threat Alert" button (placeholder for future implementation)
   - Click threat type to view details
   - Color-coded severity and status indicators

**Data Source:** Laravel API (`/api/threats`)

---

## 📄 **Threat Details** (`/threats/:id`)

### **Individual Threat View**
**Purpose:** Detailed information about a specific threat

**Features:**
1. **Threat Information:**
   - Threat type (large heading)
   - Severity score (color-coded)
   - Current status (badge)
   - Source IP address
   - Detection timestamp

2. **Threat Description:**
   - Full description of the threat
   - Attack details and characteristics

3. **Metadata:**
   - JSON-formatted metadata
   - Additional technical details
   - Attack patterns and signatures

**Navigation:** Back button to return to threats list

**Data Source:** Laravel API (`/api/threats/{id}`)

---

## 📚 **Documents** (`/documents`)

### **Document Management Page**
**Purpose:** Manage cybersecurity documents and learning materials

**Current Status:** ⚠️ **Placeholder - Coming Soon**
- Currently shows: "Document management and processing interface coming soon..."

**Planned Features:**
- Upload documents (PDF, DOCX, TXT)
- View document list
- Process documents for learning
- Download documents
- Search and filter documents
- Google Drive link integration

**Note:** The Portal (`/documents`) has full implementation. This admin page needs to be built.

---

## 🚨 **Incidents** (`/incidents`)

### **Incident Management Page**
**Purpose:** Manage security incidents and responses

**Current Status:** ⚠️ **Placeholder - Coming Soon**
- Currently shows: "Incident management interface coming soon..."

**Planned Features:**
- View all security incidents
- Create new incidents
- Update incident status
- Link incidents to threats
- Incident response tracking
- Timeline of incident events

---

## 🧪 **Simulations** (`/simulations`)

### **Simulation Management Page**
**Purpose:** Run and manage cyber-offensive simulations

**Current Status:** ⚠️ **Placeholder - Coming Soon**
- Currently shows: "Cyber-offensive simulation interface coming soon..."

**Planned Features:**
- Run defensive simulations
- Execute counter-offensive simulations
- View simulation results
- Configure simulation parameters
- Simulation history
- Attack pattern testing

**Note:** The Portal (`/simulations`) has full implementation. This admin page needs to be built.

---

## ⚙️ **Settings** (`/settings`)

### **System Settings Page**
**Purpose:** Configure system-wide settings

**Current Status:** ⚠️ **Placeholder - Coming Soon**
- Currently shows: "System settings interface coming soon..."

**Planned Features:**
- User management
- API configuration
- ML service settings
- Notification preferences
- Security policies
- System preferences
- Integration settings

---

## 🎨 **Layout & Navigation**

### **Sidebar Navigation**
Fixed left sidebar with:
- **Dashboard** (Home icon)
- **Threats** (Shield icon)
- **Documents** (Document icon)
- **Incidents** (Warning icon)
- **Simulations** (CPU icon)
- **Settings** (Cog icon)

### **Top Header**
- Page title (dynamic based on current route)
- Logout button

### **Design:**
- Dark sidebar (gray-900)
- White main content area
- Responsive grid layouts
- Tailwind CSS styling
- Professional, modern UI

---

## 🔧 **Technical Details**

### **State Management (Pinia Stores)**

#### **1. Auth Store** (`stores/auth.js`)
- Manages user authentication
- Stores JWT token
- Handles login/logout
- Token persistence in localStorage
- Auto-authentication check

#### **2. Threats Store** (`stores/threats.js`)
- Manages threat data
- Fetches threats list
- Fetches individual threat details
- Fetches threat statistics
- Updates threat information
- Loading and error states

### **API Integration**
- **Base URL:** `http://localhost:8000` (configurable via `VITE_API_URL`)
- **Authentication:** Bearer token in Authorization header
- **Endpoints Used:**
  - `POST /api/login` - User login
  - `GET /api/user` - Get current user
  - `GET /api/threats` - List threats
  - `GET /api/threats/{id}` - Get threat details
  - `GET /api/threats/statistics` - Get threat statistics
  - `PUT /api/threats/{id}` - Update threat

### **Routing**
- Protected routes (require authentication)
- Auto-redirect to login if not authenticated
- Auto-redirect to dashboard if already logged in

---

## ✅ **What's Working**

1. ✅ **Authentication System**
   - Login/logout
   - Token management
   - Protected routes

2. ✅ **Dashboard**
   - Statistics cards
   - Recent threats table
   - Real-time data from API

3. ✅ **Threats Management**
   - View all threats
   - View threat details
   - Threat statistics
   - Status and severity indicators

4. ✅ **Navigation**
   - Sidebar navigation
   - Route protection
   - Dynamic page titles

---

## 🚧 **What Needs Implementation**

1. ⚠️ **Documents Page**
   - Full CRUD operations
   - Upload/download
   - Processing interface
   - Drive link integration

2. ⚠️ **Incidents Page**
   - Incident list
   - Create/update incidents
   - Incident-threat linking
   - Response tracking

3. ⚠️ **Simulations Page**
   - Simulation interface
   - Run simulations
   - View results
   - Configuration options

4. ⚠️ **Settings Page**
   - User management
   - System configuration
   - Preferences
   - Integration settings

---

## 🚀 **How to Use**

### **1. Start the Admin Dashboard:**
```powershell
cd frontend\admin-dashboard
npm run dev
```

### **2. Access the Dashboard:**
- Open: http://localhost:5173
- You'll be redirected to `/login` if not authenticated

### **3. Login:**
- Email: `admin@sentinelai.com`
- Password: `admin123`

### **4. Navigate:**
- Use sidebar to switch between pages
- Click threats to view details
- Use logout button to sign out

---

## 📊 **Comparison: Admin Dashboard vs Portal**

| Feature | Admin Dashboard | Portal |
|---------|----------------|--------|
| **Purpose** | Administrative control | Public/user interface |
| **Authentication** | Required | Required |
| **Threats** | ✅ Full | ✅ Full |
| **Documents** | ⚠️ Placeholder | ✅ Full |
| **Simulations** | ⚠️ Placeholder | ✅ Full |
| **Analytics** | ❌ Not implemented | ✅ Full |
| **Learning** | ❌ Not implemented | ✅ Full |
| **Incidents** | ⚠️ Placeholder | ❌ Not implemented |
| **Settings** | ⚠️ Placeholder | ❌ Not implemented |

---

## 🎯 **Summary**

The **Admin Dashboard** is a professional Vue.js interface for security administrators. Currently, it provides:

✅ **Fully Working:**
- Authentication system
- Dashboard with statistics
- Threats management (view, details)
- Navigation and routing

⚠️ **Needs Implementation:**
- Documents management
- Incidents management
- Simulations interface
- Settings configuration

The dashboard is designed to be the **central control center** for security administrators, while the Portal serves as the **public-facing interface** for users.

---

**Next Steps:** Implement the placeholder pages (Documents, Incidents, Simulations, Settings) to match the functionality available in the Portal.
