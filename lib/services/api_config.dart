/// Centralised API configuration.
/// All endpoints are derived from this single [baseUrl].
/// Live production backend: https://api.techno.rku.ac.in
class ApiConfig {
  // ── Base URL ──────────────────────────────────────────────────────────────
  /// Live production base URL.  Every endpoint below is built on top of this.
  static const String baseUrl = 'https://api.techno.rku.ac.in/api';

  // ── Authentication ────────────────────────────────────────────────────────
  static String get login => '$baseUrl/auth/login';
  static String get logout => '$baseUrl/auth/logout';
  static String get profile => '$baseUrl/auth/profile';
  static String get refreshToken => '$baseUrl/auth/refresh-token';
  static String get forgotPassword => '$baseUrl/auth/forgot-password';
  static String get verifyOtp => '$baseUrl/auth/verify-otp';
  static String get resendOtp => '$baseUrl/auth/resend-otp';
  static String get resetPassword => '$baseUrl/auth/reset-password';
  static String get changePassword => '$baseUrl/auth/change-password';
  static String get register => '$baseUrl/auth/register-student';

  // ── Events (public + student) ─────────────────────────────────────────────
  static String get events => '$baseUrl/events';
  static String get upcomingEvents => '$baseUrl/events/upcoming';
  static String get completedEvents => '$baseUrl/events/completed';
  static String get myEvents => '$baseUrl/events/my-events';
  static String get searchEvents => '$baseUrl/events/search';
  static String get eventRegister => '$baseUrl/events/register';
  static String eventById(String id) => '$baseUrl/events/$id';
  static String cancelRegistration(String id) => '$baseUrl/events/register/$id';
  static String eventsByCategory(String categoryId) =>
      '$baseUrl/events/category/$categoryId';

  // ── Student portal ────────────────────────────────────────────────────────
  static String get studentDashboard => '$baseUrl/student/dashboard';
  static String get studentScores => '$baseUrl/student/scores';
  static String get studentNotifications => '$baseUrl/student/notifications';
  static String studentScoreForEvent(String eventId) =>
      '$baseUrl/student/scores/$eventId';
  static String studentRankForEvent(String eventId) =>
      '$baseUrl/student/rank/$eventId';
  static String studentLeaderboard(String eventId) =>
      '$baseUrl/student/leaderboard/$eventId';

  // ── Event pass & QR ───────────────────────────────────────────────────────
  static String eventPass(String registrationId) =>
      '$baseUrl/event-pass/$registrationId';
  static String eventQr(String registrationId) =>
      '$baseUrl/event-qr/$registrationId';

  // ── Certificates ──────────────────────────────────────────────────────────
  static String get certificates => '$baseUrl/certificates';
  static String certificateDownload(String id) =>
      '$baseUrl/certificates/$id/download';

  // ── Payments ──────────────────────────────────────────────────────────────
  /// POST — create a payment order (pass registrationId in body)
  static String get paymentCreateOrder => '$baseUrl/payment/create-order';

  /// POST — verify a gateway payment
  static String get paymentVerify => '$baseUrl/payment/verify';

  /// GET — authenticated student payment history
  static String get paymentHistory => '$baseUrl/payment/history';

  /// GET — single payment detail
  static String paymentById(String paymentId) =>
      '$baseUrl/payment/$paymentId';

  // ── Gallery ───────────────────────────────────────────────────────────────
  static String get gallery => '$baseUrl/gallery';

  /// Live API uses a path parameter for year, not a query parameter.
  static String galleryByYear(int year) => '$baseUrl/gallery/$year';

  // ── Feedback ──────────────────────────────────────────────────────────────
  static String get feedback => '$baseUrl/feedback';
  static String feedbackForEvent(String eventId) => '$baseUrl/feedback/$eventId';

  // ── Faculty portal ────────────────────────────────────────────────────────
  static String get facultyDashboard => '$baseUrl/faculty/dashboard';
  static String get facultyEvents => '$baseUrl/faculty/events';
  static String facultyEventById(String id) => '$baseUrl/faculty/events/$id';
  static String facultyParticipants(String eventId) =>
      '$baseUrl/faculty/events/$eventId/participants';
  static String facultyParticipantById(String id) =>
      '$baseUrl/faculty/participant/$id';
  static String get facultyAttendanceScan => '$baseUrl/faculty/attendance/scan';
  static String get facultyAttendanceManual =>
      '$baseUrl/faculty/attendance/manual';
  static String facultyAttendance(String eventId) =>
      '$baseUrl/faculty/attendance/$eventId';

  /// POST — enter a participant score
  static String get facultyScoreEnter => '$baseUrl/faculty/score';

  /// PUT — edit an existing score; GET — list scores for an event
  static String facultyEventScores(String eventId) =>
      '$baseUrl/faculty/score/$eventId';
  static String facultyScoreById(String id) => '$baseUrl/faculty/score/$id';

  /// POST — publish rankings for an event
  static String get facultyDeclareRank => '$baseUrl/faculty/declare-rank';

  /// GET — view published rankings for an event
  static String facultyEventRankings(String eventId) =>
      '$baseUrl/faculty/rank/$eventId';

  static String get facultyVolunteers => '$baseUrl/faculty/volunteer';
  static String facultyVolunteerById(String id) =>
      '$baseUrl/faculty/volunteer/$id';
  static String get facultyCoordinators => '$baseUrl/faculty/coordinator';
  static String get facultyPayments => '$baseUrl/faculty/payment-history';
  static String get facultyReport => '$baseUrl/faculty/report';

  // ── Volunteer / Coordinator portal ────────────────────────────────────────
  static String get volunteerDashboard => '$baseUrl/coordinator/dashboard';
  static String get volunteerEvents => '$baseUrl/coordinator/events';

  /// Live API accepts eventId as a query param: ?eventId=xxx
  static String get volunteerParticipants => '$baseUrl/coordinator/participants';
  static String get volunteerAttendance => '$baseUrl/coordinator/attendance';
  static String get volunteerAnnouncements =>
      '$baseUrl/coordinator/announcements';

  // ── Staff portal ──────────────────────────────────────────────────────────
  static String get staffProfile => '$baseUrl/staff/profile';

  // ── Admin management ──────────────────────────────────────────────────────
  static String get adminDashboard => '$baseUrl/admin/dashboard';
  static String get adminStatistics => '$baseUrl/admin/statistics';
  static String get adminEvents => '$baseUrl/admin/events';
  static String adminEventById(String id) => '$baseUrl/admin/events/$id';
  static String get adminCategories => '$baseUrl/admin/categories';
  static String adminCategoryById(String id) => '$baseUrl/admin/categories/$id';
  static String get adminStudents => '$baseUrl/admin/students';
  static String adminStudentById(String id) => '$baseUrl/admin/students/$id';

  /// Live path is /admin/faculty (not /admin/staff)
  static String get adminStaff => '$baseUrl/admin/faculty';
  static String adminStaffById(String id) => '$baseUrl/admin/faculty/$id';

  static String get adminPayments => '$baseUrl/admin/payments';
  static String adminPaymentById(String id) => '$baseUrl/admin/payments/$id';
  static String get adminPaymentRefund => '$baseUrl/admin/payment/refund';

  /// Live path is /admin/notification/send (POST broadcast)
  static String get adminSendNotification => '$baseUrl/admin/notification/send';

  /// GET list of sent announcements
  static String get adminNotifications => '$baseUrl/admin/notifications';

  // Security / audit — live paths differ from old local paths
  static String get adminAuditLogs => '$baseUrl/admin/security/logs';
  static String get adminBlockedUsers => '$baseUrl/admin/security/blocked-users';
  static String adminBlockUser(String id) =>
      '$baseUrl/admin/security/block-user/$id';
  static String adminUnblockUser(String id) =>
      '$baseUrl/admin/security/unblock-user/$id';

  // Gallery admin
  static String get adminGalleryAdd => '$baseUrl/admin/gallery';
  static String adminGalleryDelete(String id) => '$baseUrl/admin/gallery/$id';

  // Reports — live uses singular "report" not "reports"
  static String get adminEventsReport => '$baseUrl/admin/report/events';
  static String get adminPaymentsReport => '$baseUrl/admin/report/payments';
  static String get adminWinnersReport => '$baseUrl/admin/report/winners';
}
