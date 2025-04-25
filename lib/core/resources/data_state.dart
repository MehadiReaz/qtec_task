import 'package:dio/dio.dart';

abstract class DataState<T> {
  final T? data;
  final DioException? error;

  const DataState({this.data, this.error});
}

class DataSuccess<T> extends DataState<T> {
  const DataSuccess({super.data});
}

class DataFailure<T> extends DataState<T> {
  const DataFailure({super.error});
}
