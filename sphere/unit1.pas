unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls, Math;

type

  { TForm1 }

  TForm1 = class(TForm)
    EditHeightOfWindowInCentimeters: TEdit;
    EditDistanceFromWIndowInCentimeters: TEdit;
    EditHeightAboveSphereInMeters: TEdit;
    EditResolutionInPixelsPerCentimeter: TEdit;
    EditWidthOfWindowInCentimeters: TEdit;
    EditSphereRadiusInMeters: TEdit;
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    DistanceLabel: TLabel;
    RadiusLabel: TLabel;
    procedure UpdateAll(Sender: TObject);
  private

  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

const
  NUMBER_OF_POINTS = 250000;
  PI = 3.141592;
  DTHETA = 2 * PI / NUMBER_OF_POINTS;

procedure TForm1.UpdateAll(Sender: TObject);
var
  S: integer;
  a: integer;
  W, H, F: real;
  P: integer;
  OB: real;
  r: real;
  d: real;
  x, y, z: real;
  x2, y2, z2: real;
  x3, y3, z3: real;
  x4, y4: integer;
  theta: real;
  i: integer;
  phi, lambda: real;
begin
  // Note that we convert all distances to meters.
  S := StrToInt(EditSphereRadiusInMeters.Text);                  // Radius of the sphere.
  a := StrToInt(EditHeightAboveSphereInMeters.Text);             // Altitude above the surface of the sphere.
  W := StrToInt(EditWidthOfWindowInCentimeters.Text) / 100;      // Width of window.
  H := StrToInt(EditHeightOfWindowInCentimeters.Text) / 100;     // Height of window.
  F := StrToInt(EditDistanceFromWindowInCentimeters.Text) / 100; // Distance of observer from window.
  P := 100 * StrToInt(EditResolutionInPixelsPerCentimeter.Text); // Pixels per meter.

  // We make the image the right size for our observation window.
  Image1.Width := round(W * P);
  Image1.Height := round(H * P);
  // Clean the image.
  Image1.Canvas.Pen.Color := clBlack;
  Image1.Canvas.Brush.Color := clWhite;
  Image1.Canvas.FillRect(Rect(0, 0, Image1.Width, Image1.Height));

  // OB, r, d, and phi depend only on S and a and so can be calculated outside of the main loop.
  OB := Sqrt(2*S*a + a*a);
  r := S*OB / (S+a);
  d := S - (S*S / (S+a));
  phi := ArcCos(S / (S+a));

  // Display OB and r.
  DistanceLabel.Caption := 'Distance to horizon: ' + IntToStr(round(OB)) + 'm';
  RadiusLabel.Caption := 'Radius of horizon: ' + IntToStr(round(r)) + 'm';

  // And plot the points on the horizon.

  theta := 0; // Starting value of theta.

  for i:= 0 to NUMBER_OF_POINTS do
      begin
      // First set of parametric equations.
      x := r * Cos(theta);
      y := r * Sin(theta);
      z := - (a + d);
      // Second set of parametric equations.
      x2 := x;
      y2 := y * Cos(phi) - z * Sin(phi);
      z2 := y * Sin(phi) + z * Cos(phi);
      // Third set of parametric equations.
      lambda := F/y2;
      x3 := lambda * x2 ;
      y3 := F;
      z3 := lambda * z2;
      // Now check that the point is in front of the observation window.
      if y2 >= F then
         begin
         // If so we turn it into x, y cordinates.
         x4 := round(P*W/2 + P*x3);
         y4 := round(P*H/2 - P*z3);
         // And plot it!
         Image1.Canvas.Pixels[x4, y4] := clBlack;
         end;
      // Increment theta.
      theta := theta + DTHETA;
      // And go round the loop again.
      end;
end;

end.

