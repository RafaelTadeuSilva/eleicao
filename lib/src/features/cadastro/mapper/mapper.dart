/// Converte entidades de/para o mapa gravado no banco.
abstract class Mapper<T> {
  Map<String, dynamic> toMap(T entity);
  T fromMap(Map<String, dynamic> map);
}
