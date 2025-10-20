// lib/dashboard_model.dart

class DashboardData {
  final String salonOwnerName;
  final BusinessSummary summary;
  final List<Appointment> upcomingAppointments;

  DashboardData({
    required this.salonOwnerName,
    required this.summary,
    required this.upcomingAppointments,
  });
}

class BusinessSummary {
  final String dailyRevenue;
  final int totalBookings;

  BusinessSummary({
    required this.dailyRevenue,
    required this.totalBookings,
  });
}

class Appointment {
  final String time;
  final String serviceName;
  final String clientName;
  final AppointmentStatus status;

  Appointment({
    required this.time,
    required this.serviceName,
    required this.clientName,
    required this.status,
  });
}

// An enum is a special type that represents a fixed number of constant values.
enum AppointmentStatus { Confirmed, Pending }