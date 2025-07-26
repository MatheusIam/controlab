abstract class Either<L, R> {
  const Either();
  B fold<B>(B Function(L l) ifLeft, B Function(R r) ifRight);
}

class Left<L, R> extends Either<L, R> {
  final L value;
  const Left(this.value);
  @override
  B fold<B>(B Function(L l) ifLeft, B Function(R r) ifRight) => ifLeft(value);
}

class Right<L, R> extends Either<L, R> {
  final R value;
  const Right(this.value);
  @override
  B fold<B>(B Function(L l) ifLeft, B Function(R r) ifRight) => ifRight(value);
}