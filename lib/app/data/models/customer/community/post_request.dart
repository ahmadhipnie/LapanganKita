// post_request.dart
class PostRequest {
  final int idBooking;
  final String title;
  final String description;

  PostRequest({
    required this.idBooking,
    required this.title,
    required this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'id_booking': idBooking,
      'post_title': title,
      'post_description': description,
    };
  }

  Map<String, dynamic> toFormData() {
    // For multipart form data
    return {
      'id_booking': idBooking.toString(),
      'title': title,
      'description': description,
      // photo will be added separately as MultipartFile
    };
  }
}
