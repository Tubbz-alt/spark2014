package Camera_Types is

   type Signature_Type is range 0 .. 7;

   subtype Columns is Integer range 0 .. 319;
   subtype Rows    is Integer range 0 .. 199;
   subtype Widths  is Integer range 0 .. Columns'Last - Columns'First + 1;
   subtype Heights is Integer range 0 .. Rows'Last - Rows'First + 1;

   type Blob_Type is record
      signature : Signature_Type := 0;
      x         : Columns        := 0;
      y         : Rows           := 0;
      width     : Widths         := 0;
      height    : Heights        := 0;
   end record;

   No_Blob : constant Blob_Type := (0, 0, 0, 0, 0);

   subtype Blob_Range is Positive range 1 .. 251;
   subtype Valid_Blobs_Range is Natural range 0 .. Blob_Range'Last;

   type Blob_Array_Type is array (Blob_Range range <>) of Blob_Type;

   type BW_Pixel is range 0 .. 255;
   type BW_Image_Type is array (Natural range <>,
                                Natural range <>) of BW_Pixel with pack;
   subtype BW_Image_320_Type is Camera_Types.BW_Image_Type (0 .. 199, 0 .. 319);

end Camera_Types;
