module Source : sig
  type loc = {
    col: int;
    row: int;
  }

  type t = {
    source: char list list;
    cursor: loc;
  }

  val from_string : string -> t
  val move_up : t -> t
  val move_down : t -> t
  val move_left : t -> t
  val move_right : t -> t
  val delete : t -> t
  val insert : t -> string -> t
  val pp : Format.formatter -> t -> unit
end
