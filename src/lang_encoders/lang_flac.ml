(*****************************************************************************

  Liquidsoap, a programmable audio stream generator.
  Copyright 2003-2017 Savonet team

  This program is free software; you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation; either version 2 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details, fully stated in the COPYING
  file at the root of the liquidsoap distribution.

  You should have received a copy of the GNU General Public License
  along with this program; if not, write to the Free Software
  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

 *****************************************************************************)

open Lang_values
open Lang_encoders

let flac_gen params =
  let defaults =
    { Encoder.Flac.
        channels = 2 ;
        fill = None;
        samplerate = 44100 ;
        bits_per_sample = 16;
        compression = 5 }
  in
  List.fold_left
      (fun f ->
        function
          | ("channels",{ term = Int i; _}) ->
              { f with Encoder.Flac.channels = i }
          | ("samplerate",{ term = Int i; _}) ->
              { f with Encoder.Flac.samplerate = i }
          | ("compression",({ term = Int i; _} as t)) ->
              if i < 0 || i >= 8 then
                raise (Error (t,"invalid compression value")) ;
              { f with Encoder.Flac.compression = i }
          | ("bits_per_sample",({ term = Int i; _} as t)) ->
              if i <> 8 && i <> 16 && i <> 32 then
                raise (Error (t,"invalid bits_per_sample value")) ;
              { f with Encoder.Flac.bits_per_sample = i }
          | ("bytes_per_page",{ term = Int i; _}) ->
              { f with Encoder.Flac.fill = Some i }
          | ("",{ term = Var s; _}) when Utils.StringCompat.lowercase_ascii s = "mono" ->
              { f with Encoder.Flac.channels = 1 }
          | ("",{ term = Var s; _}) when Utils.StringCompat.lowercase_ascii s = "stereo" ->
              { f with Encoder.Flac.channels = 2 }
          | (_,t) -> raise (generic_error t))
      defaults params

let make_ogg params =
    Encoder.Ogg.Flac (flac_gen params)

let make params =
    Encoder.Flac (flac_gen params)
