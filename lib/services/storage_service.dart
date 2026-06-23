import '../models/result.dart';

class StorageService {

  static List<Result> history = [];

  static void saveResult(
    Result result,
  ){
    history.add(result);
  }
}