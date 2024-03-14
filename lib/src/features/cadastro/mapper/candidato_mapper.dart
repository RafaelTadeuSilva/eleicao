abstract class Mapper<T> {
  Map<String, dynamic> toMap(T aluno);
  T fromMap(Map<String, dynamic> map);
}
