import 'package:rachas/core/errors/app_exception.dart';

/// Los 4 estados que maneja cada pantalla: cargando, datos, vacío y error.
sealed class ViewState<T> {
  const ViewState();
}

final class ViewLoading<T> extends ViewState<T> {
  const ViewLoading();
}

final class ViewEmpty<T> extends ViewState<T> {
  const ViewEmpty();
}

final class ViewData<T> extends ViewState<T> {
  const ViewData(this.data);

  final T data;
}

final class ViewError<T> extends ViewState<T> {
  const ViewError(this.error);

  final AppException error;
}
