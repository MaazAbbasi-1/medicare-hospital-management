# Hospital Management Flutter App - Complete Workflow & Implementation Plan

A comprehensive architectural and implementation blueprint for completing the Flutter & Firebase Hospital Management Application covering **Patients (Users)**, **Doctors**, and **Admins**.

---

## 1. System Architecture & Role-Based Access Overview

```
                         ┌─────────────────────────────────┐
                         │   Firebase Authentication       │
                         │   (Email / Password + Auth UID) │
                         └────────────────┬────────────────┘
                                          │
                                          ▼
                         ┌─────────────────────────────────┐
                         │       RoleRouter / Splash       │
                         │   (Reads role from /users/{uid})│
                         └───────┬────────┬────────┬───────┘
                                 │        │        │
               ┌─────────────────┘        │        └─────────────────┐
               ▼                          ▼                          ▼
     ┌───────────────────┐      ┌───────────────────┐      ┌───────────────────┐
     │   Patient Portal  │      │   Doctor Portal   │      │   Admin Portal    │
     │   (Role: patient) │      │   (Role: doctor)  │      │   (Role: admin)   │
     └─────────┬─────────┘      └─────────┬─────────┘      └─────────┬─────────┘
               │                          │                          │
               ├─ Search Doctors          ├─ Manage Profile          ├─ Manage Doctors
               ├─ Book Appointment        ├─ Manage Slots & Fees     ├─ Manage Patients
               ├─ Track & Cancel          ├─ Accept/Reject/Complete  ├─ System Analytics
               └─ Consultations / Chat    └─ Patient Consultation    └─ All Appointments
```

---

## 2. Firestore Database Schema Design

### 2.1 `users` Collection (`/users/{uid}`)
```json
{
  "uid": "USER_AUTH_UID",
  "name": "John Doe",
  "email": "john@example.com",
  "phone": "+1234567890",
  "role": "patient | doctor | admin",
  "isActive": true,
  "createdAt": "2026-08-30T10:00:00Z"
}
```

### 2.2 `doctors` Collection (`/doctors/{doctorId}`)
```json
{
  "id": "DOCTOR_DOC_ID",
  "userId": "USER_AUTH_UID",
  "name": "Dr. Sarah Jenkins",
  "email": "sarah.jenkins@hospital.com",
  "phone": "+1987654321",
  "qualification": "MBBS, MD (Cardiology)",
  "specialization": "Cardiology",
  "experience": "8+ Years",
  "rating": 4.9,
  "availability": "Mon - Fri",
  "availableSlots": ["09:00 AM", "10:30 AM", "02:00 PM", "04:30 PM"],
  "fee": 1500,
  "hospitalLocation": "MediCare Central, OPD Block B",
  "aboutBio": "Specialist in preventative cardiology and heart wellness.",
  "imageEmoji": "👩‍⚕️",
  "isApproved": true,
  "isActive": true,
  "createdAt": "2026-08-30T10:00:00Z"
}
```

### 2.3 `appointments` Collection (`/appointments/{appointmentId}`)
```json
{
  "id": "APPOINTMENT_ID",
  "patientId": "PATIENT_UID",
  "patientName": "John Doe",
  "patientEmail": "john@example.com",
  "patientPhone": "+1234567890",
  "doctorId": "DOCTOR_DOC_ID or DOCTOR_USER_UID",
  "doctorName": "Dr. Sarah Jenkins",
  "doctorSpecialty": "Cardiology",
  "date": "2026-09-02",
  "slot": "10:30 AM",
  "problem": "Chest tightness and routine checkup",
  "type": "In-Person | Video Consultation",
  "fee": 1500,
  "status": "Pending | Confirmed | Completed | Cancelled | Rejected",
  "doctorNotes": "Prescribed ECG and follow up in 2 weeks.",
  "createdAt": "2026-08-30T11:00:00Z",
  "updatedAt": "2026-08-30T11:30:00Z"
}
```

---

## 3. Workflow & Feature Specifications

### 👤 Workflow 1: Patient (User)
1. **Authentication:**
   - Sign up with Name, Email, Phone, Password (`role: 'patient'`).
   - Sign in via Email & Password.
2. **Doctor Discovery & Search:**
   - Search by Doctor Name, Specialization (Cardiologist, Dermatologist, etc.), or Medical Condition.
   - Filter by Availability and Consultation Fee.
3. **Doctor Profile & Slot Selection:**
   - View Doctor bio, qualification, experience, hospital location, and patient reviews.
   - Select appointment date from calendar picker and choose an available time slot.
4. **Appointment Booking & Management:**
   - Enter patient symptoms/problem description.
   - Confirm booking (stored in Firestore `/appointments`).
   - View list of upcoming, completed, and cancelled appointments under **My Appointments**.
   - Cancel pending or confirmed appointments if needed.

---

### 👨‍⚕️ Workflow 2: Doctor
1. **Authentication & Onboarding:**
   - Doctor Sign Up / Application form: enters Medical Specialty, Qualification, Experience, Default Fee, Hospital room/block, and Initial Available Slots.
   - Account created in `/users` with `role: 'doctor'` and linked record in `/doctors`.
2. **Doctor Dashboard:**
   - Key Metrics: Total Requests, Today's Appointments, Pending, Confirmed, Completed.
   - Real-time stream of incoming patient appointment requests.
3. **Appointment Management:**
   - **Accept / Confirm**: Changes status to `Confirmed`.
   - **Reject**: Rejects request with optional reason.
   - **Complete**: Marks session as `Completed` and allows doctor to add prescription/consultation notes.
4. **Doctor Profile & Availability Management:**
   - Edit Doctor Bio, Consultation Fee, Contact Number.
   - Add/Remove available time slots (e.g., toggle "09:00 AM", "11:30 AM", etc.).
   - Toggle availability status (Active / On Leave).

---

### 🛡️ Workflow 3: Admin
1. **Authentication:**
   - Admin login routing directly to `AdminDashboardScreen`.
2. **Doctor Management:**
   - View all registered doctors with approval status, ratings, and specialties.
   - **Add Doctor**: Directly add a doctor profile.
   - **Edit / Update**: Modify doctor details or assign credentials.
   - **Approve / Deactivate / Delete**: Toggle doctor active status or delete doctor records.
3. **Patient / User Management:**
   - View all registered patient accounts, contact information, and registration dates.
   - Inspect individual patient appointment booking history.
   - Disable/Enable patient accounts.
4. **Global System Oversight & Appointments:**
   - View system-wide appointment log across all doctors.
   - Filter by date, status, or doctor.
   - Override appointment status if necessary (Emergency cancellation/reassignment).
   - High-level system statistics (Total Users, Active Doctors, Revenue / Completed Appointments).

---

## 4. Implementation Roadmap & File Changes

| Phase | Module | Target Files | Key Tasks |
|:---|:---|:---|:---|
| **Phase 1** | **Auth & Role Architecture** | [auth_service.dart](file:///c:/Users/nn/Desktop/Antigravity/hospital-management/lib/services/auth_service.dart)<br>[signup_screen.dart](file:///c:/Users/nn/Desktop/Antigravity/hospital-management/lib/screens/signup_screen.dart)<br>[login_screen.dart](file:///c:/Users/nn/Desktop/Antigravity/hospital-management/lib/screens/login_screen.dart)<br>[role_router.dart](file:///c:/Users/nn/Desktop/Antigravity/hospital-management/lib/screens/role_router.dart) | • Add Role selector to Signup (Patient vs Doctor registration)<br>• Handle Doctor profile initialization upon signup<br>• Verify role fetching and routing across Firebase & local fallback |
| **Phase 2** | **Doctor Profile & Schedule Hub** | [doctor_dashboard_screen.dart](file:///c:/Users/nn/Desktop/Antigravity/hospital-management/lib/screens/doctor_dashboard_screen.dart)<br>`doctor_profile_edit_screen.dart` *(New)*<br>[data_service.dart](file:///c:/Users/nn/Desktop/Antigravity/hospital-management/lib/services/data_service.dart) | • Add "Edit Profile & Availability" screen for doctors<br>• Slot management (add/remove time slots)<br>• Add doctor notes field when marking appointment completed |
| **Phase 3** | **Patient Search & Booking Polish** | [home_screen.dart](file:///c:/Users/nn/Desktop/Antigravity/hospital-management/lib/screens/home_screen.dart)<br>[booking_screen.dart](file:///c:/Users/nn/Desktop/Antigravity/hospital-management/lib/screens/booking_screen.dart)<br>[doctor_detail_screen.dart](file:///c:/Users/nn/Desktop/Antigravity/hospital-management/lib/screens/doctor_detail_screen.dart)<br>[appointments_screen.dart](file:///c:/Users/nn/Desktop/Antigravity/hospital-management/lib/screens/appointments_screen.dart) | • Dynamic doctor listing pulling directly from Firestore `/doctors`<br>• Real-time slot availability check (prevent double booking)<br>• Cancel appointment modal for patient |
| **Phase 4** | **Full Admin Management Suite** | [admin_dashboard_screen.dart](file:///c:/Users/nn/Desktop/Antigravity/hospital-management/lib/screens/admin_dashboard_screen.dart)<br>`admin_doctors_screen.dart` *(New)*<br>`admin_users_screen.dart` *(New)*<br>`admin_appointments_screen.dart` *(New)* | • Interactive Doctor Management (Add, Edit, Approve, Delete)<br>• Patient Directory with booking history viewer<br>• System-wide appointments filter and status controller |
| **Phase 5** | **Security & Verification** | [firestore.rules](file:///c:/Users/nn/Desktop/Antigravity/hospital-management/firestore.rules) | • Update Firestore security rules for role-based write/read permissions<br>• Validate indexing for compound queries (`role`, `status`, `date`) |

---

## 5. Firestore Security Rules Configuration

Ensure [firestore.rules](file:///c:/Users/nn/Desktop/Antigravity/hospital-management/firestore.rules) allows the full 3-role workflow:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    function signedIn() { return request.auth != null; }
    function getUserData() {
      return get(/databases/$(database)/documents/users/$(request.auth.uid)).data;
    }
    function role(name) {
      return signedIn() && getUserData().role == name;
    }
    function admin() { return role('admin'); }
    function doctor() { return role('doctor'); }

    // Users Collection
    match /users/{userId} {
      allow read: if signedIn() && (request.auth.uid == userId || admin() || doctor());
      allow create: if signedIn() && request.auth.uid == userId;
      allow update: if signedIn() && (request.auth.uid == userId || admin());
      allow delete: if admin();
    }

    // Doctors Collection
    match /doctors/{doctorId} {
      allow read: if signedIn();
      allow create: if admin() || (signedIn() && request.resource.data.userId == request.auth.uid);
      allow update: if admin() || (doctor() && resource.data.userId == request.auth.uid);
      allow delete: if admin();
    }

    // Appointments Collection
    match /appointments/{appointmentId} {
      allow read: if admin() ||
        (signedIn() && resource.data.patientId == request.auth.uid) ||
        (doctor() && (resource.data.doctorId == request.auth.uid || resource.data.doctorName == getUserData().name));
      allow create: if signedIn() && request.resource.data.patientId == request.auth.uid;
      allow update: if admin() ||
        (doctor() && (resource.data.doctorId == request.auth.uid || resource.data.doctorName == getUserData().name)) ||
        (signedIn() && resource.data.patientId == request.auth.uid);
      allow delete: if admin() || (signedIn() && resource.data.patientId == request.auth.uid);
    }
  }
}
```

---

## 6. End-to-End Verification Checklist

- [ ] **Patient Test**:
  1. Sign up as Patient -> lands on `HomeScreen`.
  2. Search for a doctor (e.g. Cardiologist).
  3. Select doctor, pick date & slot -> Book Appointment.
  4. Navigate to `AppointmentsScreen` -> Status displays "Pending".
- [ ] **Doctor Test**:
  1. Sign up/in as Doctor -> lands on `DoctorDashboardScreen`.
  2. Verify pending appointment appears in real-time.
  3. Click "Confirm" -> Check status changes to "Confirmed".
  4. Edit profile & update fee / time slots -> Confirm updates reflect in patient search.
  5. Mark appointment as "Completed" with notes.
- [ ] **Admin Test**:
  1. Sign in with Admin credentials -> lands on `AdminDashboardScreen`.
  2. View live stat counters (Doctors, Patients, Appointments, Pending).
  3. Open Doctor Management -> Add / Edit doctor details.
  4. Open Patient Management -> Inspect registered users.
  5. Open Global Appointments -> Filter and oversee all appointments.
