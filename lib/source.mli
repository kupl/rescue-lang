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
val move_to_origin : t -> t
val delete : t -> t
val insert : string -> t -> t
val pp : ?with_display:bool -> ?with_cursor:bool -> Format.formatter -> t -> unit
