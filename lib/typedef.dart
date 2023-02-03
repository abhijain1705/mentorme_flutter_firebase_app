import 'package:fpdart/fpdart.dart';
import 'package:mentor_me/failure.dart';

typedef FutureEither<T> = Future<Either<Failure, T>>;
typedef FutureVoid = FutureEither<void>;
