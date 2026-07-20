import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../error/failures.dart';

/// Contract every use case implements. Keeps blocs thin: a bloc calls a single
/// use case and maps `Either<Failure, Type>` to a state.
///
/// `Type` is the success payload; `Params` is the input (use [NoParams] when
/// none is needed).
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

/// Synchronous variant (e.g. reading a cached flag).
abstract class SyncUseCase<Type, Params> {
  Either<Failure, Type> call(Params params);
}

/// Placeholder for use cases that take no arguments.
class NoParams extends Equatable {
  const NoParams();
  @override
  List<Object?> get props => [];
}
