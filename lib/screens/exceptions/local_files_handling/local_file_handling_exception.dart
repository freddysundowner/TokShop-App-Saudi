import '../../../utils/text.dart';

abstract class LocalFileHandlingException {
  final String _message;
  LocalFileHandlingException(this._message);
  String get message => _message;
  @override
  String toString() {
    return message;
  }
}

class LocalFileHandlingStorageReadPermissionDeniedException
    extends LocalFileHandlingException {
  LocalFileHandlingStorageReadPermissionDeniedException(
      {String message =storage_Read_permissions_not_granted})
      : super(message);
}
