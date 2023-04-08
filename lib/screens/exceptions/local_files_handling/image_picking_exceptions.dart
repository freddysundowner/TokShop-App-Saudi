import '../../../utils/text.dart';
import 'local_file_handling_exception.dart';

class LocalImagePickingException extends LocalFileHandlingException {
  LocalImagePickingException(
      {String message =instance_of_image_picking_exception})
      : super(message);
}

class LocalImagePickingInvalidImageException
    extends LocalImagePickingException {
  LocalImagePickingInvalidImageException(
      {String message = invalid_image})
      : super(message: message);
}

class LocalImagePickingFileSizeOutOfBoundsException
    extends LocalImagePickingException {
  LocalImagePickingFileSizeOutOfBoundsException(
      {String message = image_size_range})
      : super(message: message);
}

class LocalImagePickingInvalidImageSourceException
    extends LocalImagePickingException {
  LocalImagePickingInvalidImageSourceException(
      {String message = image_source_invalid})
      : super(message: message);
}

class LocalImagePickingUnknownReasonFailureException
    extends LocalImagePickingException {
  LocalImagePickingUnknownReasonFailureException(
      {String message = failed_due_to_unknown_reason})
      : super(message: message);
}
