
let sum = List.fold_left (+.) 0.

let mul_sum xs ys = sum (List.map2 ( *.) xs ys)

let make_vs wss ys = List.map (mul_sum ys) wss

let c = 50.
let c' = 10.
let h = 0.5
let k = -1.0

let f u =
  let a = ~-.c *. u in
  let a' = c' *. (abs_float u -. h) in
    (1. -. exp a) *. (1. +. k *. exp a') /. (1. +. exp a) /. (1. +. exp a')

let m = 10
let n = 100
let _ = Random.self_init ()

let rec make_list n = 
  let i = ref (n-1) in
  let list = ref [] in
    while !i >= 0 do
      list := !i :: !list;
      decr i
    done;
    !list

let gen_list start next last = 
  if start = next
  then failwith "gen_list: next is equal to start"
  else
  let i = ref start in
  let list = ref [] in
  let step = next - start in
  let cont =
    if step > 0
    then fun i -> i <= last
    else fun i -> i >= last in
    begin
      while cont !i do
	list := !i :: !list;
	i := !i + step;
      done;
      List.rev !list
    end

let make_random_pattern n =
  (* FIXME: 0 -> 0. *)
  List.map (fun _ -> if Random.bool () then 1 else -1) (make_list n)

let q = List.map (fun _ -> make_random_pattern n) (make_list m)

let a = 4

let rec make_smooth_pattern a x y = 
  if a = 1
  then [x]
  else
    let count_diff x y =
      List.fold_left2 (fun n x y -> if x = y then n else n+1) 0 x y in
    let turn x y n =
      let i = ref 0 in
	List.map2
	  (fun x y ->
	     if x = y or !i >= n
	     then x
	     else (incr i; y))
	  x y in
    let next x y a =
      turn x y (count_diff x y / a) in
      x :: make_smooth_pattern (a-1) (next x y a) y
  

let make_s q a =
  List.flatten (List.map2 (make_smooth_pattern a)
		  q (List.tl q @ [List.hd q]))

let s = make_s q a

let s1 = List.hd s
let s2 = List.hd (List.tl s)

let ss0_ss1 ss0 ss1 = List.map (fun s1 -> List.map (fun s0 -> s1 * s0) ss0) ss1

let fold_l2 f = function
    [] -> failwith "fold_l2"
  | x::xs -> List.fold_left f x xs

let add_w = List.map2 (List.map2 (+))

let make_wss s =
  let sum_w = fold_l2 add_w in
  let div_n_a w = float_of_int w /. float_of_int n /. float_of_int a in
    List.map (List.map div_n_a)
      (sum_w (List.map2 ss0_ss1 s (List.tl s @ [List.hd s])))

let wss = make_wss s

let make_ys = List.map f

let tau = 0.01

let next_us us = 
  let ys = make_ys us in
  let vs = make_vs wss ys in
    List.map2 (fun u v -> u +. (v -. u) *. tau) us vs

let init_us = List.map 
		(fun x -> float_of_int x *. 0.1)
		(List.hd q)

let make_xs =
  let step x =
    if x >= 0.
    then 1
    else -1 in
    List.map step

let make_p xs ss = 
  let mul_sum xs ss = fold_l2 (+) (List.map2 ( * ) xs ss) in
    float_of_int (mul_sum xs ss) /. float_of_int n

let rec take n = function
    [] -> []
  | x::xs -> if n=0
    then []
    else x :: (take (n-1) xs)

let rec iterater n f a =
  if n=0
  then ()
  else iterater (n-1) f (f a)

let make_ps =
  let ss = (take 7 s) in
    fun us ->
      List.map (make_p (make_xs us)) ss

let iter_sp f sp = function
    [] -> ()
  | x::xs ->
      f x;
      List.iter (fun x -> sp (); f x) xs

let print_floats xs =
  let print_tab () = print_string "\t" in
  iter_sp print_float print_tab xs;
  print_newline ()

let main us =
  print_floats (make_ps us);
  next_us us

(*
let main us =
  print_floats us;
  next_us us
*)

let _ = iterater 1000 main init_us


(*  *)
