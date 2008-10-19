(*****************************************************************************

  Liquidsoap, a programmable audio stream generator.
  Copyright 2003-2008 Savonet team

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

open Source

class effect effect (source:source) =
object (self)
  inherit operator [source] as super

  method stype = source#stype

  method remaining = source#remaining

  method is_ready = source#is_ready
  method abort_track = source#abort_track

  method get_frame buf =
    let offset = AFrame.position buf in
      source#get buf ;
      let b = VFrame.get_rgb buf in
      let position = VFrame.position buf in
        for c = 0 to Array.length b - 1 do
          let bc = b.(c) in
            for i = offset to position - 1 do
              effect bc.(i)
            done
        done
end

let () =
  Lang.add_operator "video.greyscale"
    [ "", Lang.source_t, None, None ]
    ~category:Lang.VideoProcessing
    ~descr:"Convert video to greyscale."
    (fun p ->
       let f v = List.assoc v p in
       let src = Lang.to_source (f "") in
         ((new effect RGB.greyscale src):>source))

let () =
  Lang.add_operator "video.invert"
    [ "", Lang.source_t, None, None ]
    ~category:Lang.VideoProcessing
    ~descr:"Invert video."
    (fun p ->
       let f v = List.assoc v p in
       let src = Lang.to_source (f "") in
         ((new effect RGB.invert src):>source))

let () =
  Lang.add_operator "video.lomo"
    [ "", Lang.source_t, None, None ]
    ~category:Lang.VideoProcessing
    ~descr:"Emulate the \"Lomo effect\"."
    (fun p ->
       let f v = List.assoc v p in
       let src = Lang.to_source (f "") in
         ((new effect RGB.lomo src):>source))

let () =
  Lang.add_operator "video.fill"
    [
      "color", Lang.int_t, Some (Lang.int 0), Some "Color to fill the image with.";
      "", Lang.source_t, None, None
    ]
    ~category:Lang.VideoProcessing
    ~descr:"Fill frame with a color."
    (fun p ->
       let f v = List.assoc v p in
       let color, src =
         Lang.to_int (f "color"),
         Lang.to_source (f "")
       in
       let r,g,b = RGB.rgb_of_int color in
         ((new effect (fun buf -> RGB.fill buf (r, g, b, 0xff)) src):>source))

let () =
  Lang.add_operator "video.scale"
    [
      "coef", Lang.float_t, Some (Lang.float 1.), Some "Scaling coefficient in both directions.";
      "coef_x", Lang.float_t, Some (Lang.float 1.), Some "x scaling";
      "coef_y", Lang.float_t, Some (Lang.float 1.), Some "y scaling";
      "offset_x", Lang.int_t, Some (Lang.int 1), Some "x offset";
      "offset_y", Lang.int_t, Some (Lang.int 1), Some "y offset";
      "", Lang.source_t, None, None
    ]
    ~category:Lang.VideoProcessing
    ~descr:"Scale and translate video."
    (fun p ->
       let f v = List.assoc v p in
       let src = Lang.to_source (f "") in
       let c, cx, cy, ox, oy =
         Lang.to_float (f "coef"),
         Lang.to_float (f "coef_x"),
         Lang.to_float (f "coef_y"),
         Lang.to_int (f "offset_x"),
         Lang.to_int (f "offset_y")
       in
         ((new effect (fun buf -> RGB.affine buf (c*.cx) (c*.cy) ox oy) src):>source))

let () =
  let effect a da buf =
    a := !a +. da;
    RGB.rotate buf !a
  in
  Lang.add_operator "video.rotate"
    [
      "angle", Lang.float_t, Some (Lang.float 0.), Some "Initial angle in radians.";
      "speed", Lang.float_t, Some (Lang.float 3.1416), Some "Rotation speed in radians per sec.";
      "", Lang.source_t, None, None
    ]
    ~category:Lang.VideoProcessing
    ~descr:"Rotate video."
    (fun p ->
       let f v = List.assoc v p in
       let src = Lang.to_source (f "") in
       let angle = ref (Lang.to_float (f "angle")) in
       let speed = Lang.to_float (f "speed") in
       let da = speed /. float (Fmt.video_frames_per_second ()) in
         ((new effect (effect angle da) src):>source))
