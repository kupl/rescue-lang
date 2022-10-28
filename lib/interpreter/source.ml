module Source = struct
  type loc = {
    col: int;
    row: int;
  }

  type t = {
    source: char list list;
    cursor: loc;
  }

  let from_string (source : string) : t =
    let col = 0 in
    let row = 0 in
    let cursor = { col; row } in
    let source = String.split_on_char '\n' source in
    let source = List.map (fun line -> String.to_seq line |> List.of_seq) source in
    { source; cursor }

  let get_current_row (source : t) : char list = List.nth source.source source.cursor.row

  let split (source : t) : string * string =
    let front =
      Core.List.take source.source source.cursor.row
      |> List.map List.to_seq
      |> List.map String.of_seq
      |> String.concat "\n"
    in
    let front =
      front
      ^ (if String.length front > 0 then "\n" else "")
      ^ (Core.List.take (get_current_row source) source.cursor.col |> List.to_seq |> String.of_seq)
    in
    let rear =
      Core.List.drop (get_current_row source) source.cursor.col |> List.to_seq |> String.of_seq
    in
    let rear =
      rear
      ^ "\n"
      ^ (Core.List.drop source.source (source.cursor.row + 1)
        |> List.map List.to_seq
        |> List.map String.of_seq
        |> String.concat "\n")
    in
    front, rear

  let trim_row_loc (source : t) (row : int) : int =
    row |> max 0 |> min (List.length source.source - 1)

  let trim_col_loc (source : t) (col : int) : int =
    col |> max 0 |> min (List.length (get_current_row source))

  let trim_loc (source : t) (loc : loc) : loc =
    { row = trim_row_loc source loc.row; col = trim_col_loc source loc.col }

  let move_up (source : t) : t =
    { source with cursor = { source.cursor with row = source.cursor.row - 1 } |> trim_loc source }

  let move_down (source : t) : t =
    { source with cursor = { source.cursor with row = source.cursor.row + 1 } |> trim_loc source }

  let move_left (source : t) : t =
    { source with cursor = { source.cursor with col = source.cursor.col - 1 } |> trim_loc source }

  let move_right (source : t) : t =
    { source with cursor = { source.cursor with col = source.cursor.col + 1 } |> trim_loc source }

  let delete (source : t) : t =
    match source.cursor with
    | { row = 0; col = 0 } -> source
    | { row; col = 0 } ->
        let front_rows = Core.List.take source.source (row - 1) in
        let prev_row = List.nth source.source (row - 1) in
        let current_row = List.nth source.source row in
        let current_row = prev_row @ current_row in
        let rear_rows = Core.List.drop source.source (row + 1) in
        {
          source = front_rows @ [current_row] @ rear_rows;
          cursor = { row = row - 1; col = List.length prev_row };
        }
    | { row; col } ->
        let front_rows = Core.List.take source.source row in
        let current_row = List.nth source.source row in
        let current_row = Core.List.take current_row (col - 1) @ Core.List.drop current_row col in
        let rear_rows = Core.List.drop source.source (row + 1) in
        { source = front_rows @ [current_row] @ rear_rows; cursor = { row; col = col - 1 } }

  let insert (str : string) (source : t) : t =
    let str = str |> String.to_seq |> List.of_seq in
    let { row; col } = source.cursor in
    let front_rows = Core.List.take source.source row in
    let current_row = List.nth source.source row in
    let current_row = Core.List.take current_row col @ str @ Core.List.drop current_row col in
    let rear_rows = Core.List.drop source.source (row + 1) in
    {
      source = front_rows @ [current_row] @ rear_rows;
      cursor = { row; col = col + List.length str };
    }

  let pp (formatter : Format.formatter) (source : t) : unit =
    let front, back = split source in
    let current_char = String.get back 0 in
    let back = String.sub back 1 (String.length back - 1) in
    Format.fprintf formatter "%s" front;
    if current_char = '\n' then Format.fprintf formatter "\027[30;47m \027[m\n"
    else Format.fprintf formatter "\027[30;47m%c\027[m" current_char;
    Format.fprintf formatter "%s" back
end