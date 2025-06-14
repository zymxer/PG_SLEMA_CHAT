class Chat {
  final String id;
  final bool isGroup;
  String name;

  Chat(this.id, this.name, this.isGroup);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Chat && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}