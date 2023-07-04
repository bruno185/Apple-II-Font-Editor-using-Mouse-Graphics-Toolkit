      
   
procedure DoVide;
   var
      i: integer;
   begin
      for i:= 1 to col do
      libl[i]:= '';
      for i:= 1 to lig do
      libc[i]:= '';
      fillchar(ta,sizeof(ta),0);
      fillchar(t,sizeof(t),0);
      fillchar(t0,sizeof(t0),0);
      m:=0; n:= 0;
      calc:= false;
   end;
      
      
procedure  MakeRect (var r : rect; a,b,c,d : integer);
    begin
      r.left := a;
      r.top := b;
      r.right := c;
      r.bottom := d;
    end;

procedure InitRect;
   VAR
      i: integer;
   begin
      for i:= 1 to 5 do
      MakeRect (ca[i],34,12*i-5,54,12*i+6);
      for i:= 1 to 5 do
      MakeRect (ca[5+i],264,12*i-5,284,12*i+6);
   end;
   
PROCEDURE ARRONDI (VAR K:REAL);

VAR Z,SIGNE:REAL;
BEGIN
Z:=0;SIGNE:=1;
IF K<0 THEN 
        BEGIN
        SIGNE:=-1;
        K:=K*(-1);
        END;
WHILE ( K > 32767.0) OR (K<-32767.0) DO
        BEGIN
        K:=K-10000;
        Z:=Z+1;
        END;
K:=ROUND (K)+Z*10000;K:=K*SIGNE;
END;
      
procedure IntStr (k: integer; var s: string);
   var 
      negatif: boolean;
      d_str: string[1];
   begin
      negatif:= k<0;
      k:= abs(k);
      s:= '';
      d_str:= '0';
      {$R-}
      repeat
         d_str[1]:= chr(ord('0')+k mod 10);
         s:= concat (d_str,s);
         k:= k div 10;
      until k=0;
      if negatif then s:= concat('-',s);
      {$R+}
   end;
   
procedure DessInt (x:integer);
   var
      s: string;
   begin
      intstr(x,s);
      drawtext(s);
   end;
   
function Strint (chain: string):integer;
   var
      i,j,k,l: integer;
   begin
      l:=0;
      for i:= 1 to length(chain) do
         begin
         
            j:= length(chain)-i;
            case j of
            4: k:= 10000;
            3: k:= 1000;
            2: K:= 100;
            1: k:= 10;
            0: k:= 1;
            end;
            
            l:= l+k*(ord(chain[i]) - ord('0'));
         end;
      Strint:= l;
      end;

procedure Dessreel (Re: real);
   {$R-}
   var
      re1,re2,re3: real;
      cycle: integer;
      chain: string;
      chain2:string;
      
   begin
      if (re > (-1)*maxint) and (re < maxint) then
         begin
            Dessint(round(re));
            exit(Dessreel);
         end;
      cycle:= 0;
      if re<0 then 
         begin
            drawtext('-');
            re:= re*(-1);
         end;
      re1:= re;
      while re1>maxint  do
         begin
            cycle:= cycle+1;
            re1:= re1-10000;
         end;
      IntStr(round(re1),chain);
      chain2:= '0';
      chain2[1]:= chain[1];
      cycle:= cycle+Strint(chain2);
      Dessint(cycle);
      delete(chain,1,1);
      drawtext(chain);
            
   end;
      {]R+}
   
   
    
 procedure Input (x:integer;y:integer;z:integer;w:integer;max:integer;
                  code:integer;var chaine:string );
    {R-}
    var
       del:boolean;
       asc,i:integer;
       lettre: string[1];
       
    procedure InitInput;
       begin
          i:= 0;
          del:= true;
          asc:= 0;
          moveto (x,y);
       end;
    
       
    
    procedure Prompt (var del:boolean);
          var
             carac: string;
          begin
             carac:= '?';
             carac[1]:= chr(z);
             if del then
                   drawtext (carac)
             else begin carac:= '  ';  drawtext(carac);end;
             move(TextWidth(carac)*(-1) ,0);
             del:= not (del);
             i:= 0;
          end;
    
          
       procedure Ecrire (asc:integer);
          var
             carac:string;
             long: integer;
          begin
             carac:='?';
             if asc= 8   then
                begin 
                   if length(chaine)=0 then
                   begin
                      SoundBell;
                      exit(Ecrire);
                   end;
                   if del=false then Prompt(del);
                   carac[1]:= chaine[length(chaine)];
                   long:= TextWidth(carac)*(-1);
                   move(long,0);
                   drawtext('  ');
                   move(TextWidth('  ')*(-1),0);
                   exit(Ecrire);
                end;
             carac[1]:= chr(asc);
             drawtext(carac);
          end;
          
          
       
    begin  { Input }
       InitInput;
       repeat
          begin
             repeat
                begin
                   i:= i+1;
                   GetEvent (event);
                   if i=15 then Prompt(del);
                   if event.evt_kind= button_down then
                      begin
                         with event do
                            begin
                               screenx:=char1+256*char2;
                               screeny:=char3+256*char4;
                               ScreenToWindow(w,screenx,screeny,windowx,
                               windowy);
                            end;
                         if (r.left<= windowx) and (r.right>=windowx) 
                         and (r.top<= windowy) and (r.bottom>=windowy) then 
                         begin
                            if del= false then Prompt(del);
                            annul:= true;
                            exit(Input);
                         end;
                         
                         if (r1.left<= windowx) and (r1.right>=windowx)
                         and (r1.top<= windowy) and (r1.bottom>= windowy) then
                            begin
                               if length(chaine)= 0 then SoundBell 
                               else
                                  begin
                                     if del= false then Prompt(del);
                                     if code= 1 then SoundBell;
                                     if code= 2 then exit(Input);
                                     if code= 4 then
                                        begin
                                           Valid:= true;
                                           exit(Input);
                                        end;
                                  end;
                            end;
                         
                         if (code=4) and (windowx>5) and (windowx<= (
                         5+(n+1)*47)) and (windowy>=5) and (windowy
                         <5+(m+1)*13) then click:=true;
                         
                         if (code=4) and  (windowx<
                         52) and (windowy<18)
                         then click:= false;
                         
                         if click=true then 
                            begin
                               if del= false then Prompt(del);
                               exit(Input);
                            end;
                               
                            
                      end;
                               
                end;
             until event.evt_kind= key_down;
             asc:= ord (event.char1);
             if asc= 13 then begin
                                if del=false then Prompt(del);
                                if length(chaine)=0 then 
                                   begin
                                      if code= 4 then SoundBell
                                      else
                                         begin
                                            annul:=true;
                                            exit(Input);
                                         end;
                                   end
                                else
                                   begin
                                      if code= 1 then exit(Input);
                                      if code= 2 then 
                                         begin
                                            valid:= true;
                                            exit(Input);
                                         end;
                                      if code= 4 then exit(Input);
                                   end;
                             end
             else
             begin
                             
             if (length(chaine)<=max) or (asc=8) then
                begin
                   if del= false then Prompt(del);
                   Ecrire(asc);
                   if asc<> 8 then 
                      begin
                         lettre:= ' ';lettre[1]:= chr(asc);
                         chaine:= concat(chaine,lettre);
                      end
                   else 
                      if length(chaine)>0 then
                         delete(chaine,length(chaine),1);
                end
                else SoundBell;
             end;
          end;
       until asc=13;
     {R+}
    end;
    
       
       
procedure  DrawIt (which_window : integer);
    var
        i,j,k,mode : integer;
        temp : string[1];
        tempo : string;
        p : integer;
        p_ref : ^grafport;
        carre: integer;
        
  procedure Sortir(w: integer);
     begin
        CloseWindow(W);
        exit (DrawIt);
     end;
     
 procedure Annuler;
    begin
       paintrect(r);
       moveto(22,161);
       SetTextBG(0);
       drawtext(' ANNULER');
       SetTextBG(127);
    end;
    
 procedure Valider;
    begin
       paintrect(r1);
       moveto (242,161);
       SetTextBG(0);
       drawtext(' VALIDER');
       SetTextBG(127);
    end;
     
  procedure Cadre;
     begin
            makerect(r,20,151,TextWidth('  ANNULER ')+20,162);
            framerect(r);
            moveto (22,161);
            drawtext(' ANNULER');
            makerect(r1,240,151,TextWidth('  VALIDER ')+240,162);
            framerect (r1);
            moveto (242,161);
            drawtext(' VALIDER');
    end;
     
  function Test(chain: string):boolean;
     var
        i: integer;
     begin
        Test:= true;
        for i:= 1 to length (chain) do
           begin
              if (ord(chain[i]) < ord('0')) or (ord(chain[i]) > ord('9'))
              then Test:= false;
           end;
    end;
    
    procedure InputLigCol;
       var
          i: integer;
       begin
          moveto(100,50);
          drawtext('Nombre de lignes =  ');
          moveto(100,100);
          drawtext('Nombre de colonnes =');
          mode:= 1;
          for i:= 1 to 2 do
             begin
                repeat
                   tempo:= '';annul:= false;
                   moveto(220,50*i);drawtext('     ');
                   Input(220,50*i,26,W2,1,mode,tempo);
                   if annul then 
                      begin
                         Annuler;
                         Dovide;
                         Sortir(W2);
                      end;
                until (Test(tempo)=true) and (Strint(tempo) > 2) and (Strint
                (tempo) < 11);
                if i= 1 then m:=Strint(tempo) else n:= Strint(tempo);
             end;
          moveto (100,50);
          for i:= 1 to 10 do
             begin
                drawtext('       ');
             end;
          moveto (100,100);
          for i:= 1 to 10 do
             begin
               drawtext('       ');
             end;
       end;
       
   procedure Tableau;
   var i,j: integer;
   begin
      for i:= 0 to m do
         begin
            moveto(5,18+i*13);
            line (47+n*47,0);
         end;
      for i:= 0 to n do
         begin
            moveto(52+47*i,5);
            line (0,13+m*13);
         end;
      for i:= 0 to m-1 do
         begin
            moveto(6,30+13*i);
            drawtext (libl[i+1]);
         end;
      for i:= 0 to n-1 do 
         begin
            moveto(54+47*i,17);
            drawtext(libc[i+1]);
         end;
      for i:= 0 to m-1 do
         begin
            for j:= 0 to n-1 do
               begin
                  moveto(54+j*47,30+13*i);
                  DessInt(t[i+1,j+1]);
               end;
         end;
      end;
      
      
procedure Entrer;
      
         begin
            Cadre;
            InputLigCol ;
            for i:= 0 to m do
               begin
                  moveto(5,18+i*13);
                  line(47+n*47,0);
               end;
            for i:= 0 to n do 
               begin
                  moveto(52+47*i,5);
                  line(0,13+m*13);
               end;
               
           annul:= false; mode:= 1;
            
            { Libelle des lignes }
            for i:= 0 to m-1 do
               begin
                  Input (6,30+13*i,26,W2,4,mode,libl[i+1]);
                  if annul then 
                     begin
                        Annuler;
                        Dovide;
                        Sortir(W2);
                     end;
               end;
               
            { Libelle des colonnes }
            for i:= 0 to n-1 do
               begin
                  Input (54+47*i,17,26,W2,4,mode,libc[i+1]);
                  if annul then 
                  begin
                     Annuler;
                     Dovide;
                     Sortir(W2);
                  end;
               end;
               
            {  les cases  }
            
            for i:= 0 to m-1 do
               begin
                  for j:= 0 to n-1 do
                     begin
                        repeat
                           begin
                              moveto(54+j*47,30+i*13);
                              drawtext('        ');
                              tempo:= '';annul:= false;
                              if (i=m-1) and (j=n-1) then mode:= 2;
                              Input(54+j*47,30+i*13,26,W2,4,mode,tempo);
                              if annul = true then 
                                 begin
                                    Annuler;
                                    Dovide;
                                    Sortir(W2);
                                 end;
                           end;
                        until (Test(tempo)= true) and (Strint(tempo)>=0)
                         and (Strint(tempo)<maxint-1);
                        t[i+1,j+1]:= Strint(tempo);
                     end;
                 end;
             Valider;
             Sortir(W2);
         end;
      
  procedure Modif;
     var i,j,a: integer;
     tint: tab;
     lil: packed array[1..lig] of string[5];
     lic: packed array[1..col] of string[5];
        
        procedure Getlibl;
            begin
                  repeat
                     begin
                        mode:= 4;annul:= false;valid:= false; click:=
                        false;
                        if length(lil[i-1])<=0 then a:=0 else
                        a:= TextWidth(lil[i-1]);
                        Input (6+a,17+13*(i-1),26,W5,4,
                        mode,lil[i-1]);
                        if annul then 
                           begin
                              Annuler;
                              Sortir(W5);
                           end;
                     end;
               until length(lil[i-1])>0;
            end;
      
      
      procedure Getlibc;
         begin
            repeat
               begin
                  mode:= 4; annul:= false; valid:= false;
                  click:= false;
                  if length(lic[j-1])<=0 then a:=0 else
                  a:= TextWidth(lic[j-1]);
                  Input (7+47*(j-1)+a,17,26,W5,4,
                  mode,lic[j-1]);
                  if annul then 
                     begin
                        Annuler;
                        Sortir(W5);
                     end;
               end;
         until length (lic[j-1])>0;
      end;
      
   
   procedure  Getcase;
      begin
         repeat
            begin
               IntStr(tint[i-1,j-1],tempo);  
               annul:= false;
               mode:= 4;
               valid:=false;
               click:= false;
               moveto (7+(j-1)*47,17+13*(i-1));
               drawtext('       ');
               moveto (7+(j-1)*47,17+13*(i-1));
               drawtext(tempo);
               Input(7+(j-1)*47+TextWidth
               (tempo),17+(i-1)*13,26,W5,4,mode,tempo);
               if annul = true then 
                  begin
                     Annuler;
                     Sortir(W5);
                  end;
            end;
         until (Test(tempo)= true) and (length(Tempo)>0)
         and (Strint(tempo)>=0) and (Strint(tempo)
         <maxint-1);
             if Tint[i-1,j-1]<> Strint(tempo) then
                begin
                   calc:= false;
                   Tint[i-1,j-1]:= Strint(tempo);
                end;
      end;
      
   procedure OK;
      begin
         libl:= lil;
         libc:= lic;
         t:= tint;
         Valider;
         Sortir(W5);
      end;

procedure Nextij;
   begin
      case click of
      
      false: begin
                if j=1 then
                   begin
                      if i<m+1 then i:= i+1
                      else i:=2;
                   end;
                if i=1 then
                   begin
                      if j< n+1 then j:=j+1
                      else j:= 2;
                   end;
                if (i>1) and (j>1) then 
                   begin
                      if (i=m+1) and (j=n+1) then
                         begin
                            i:=2;j:=2;
                         end
                      else if j<n+1 then j:=j+1
                      else begin
                              j:=2;
                              i:=i+1;
                           end;
                    end;
              end;
              
      true: begin
               j:= trunc((windowx-5) div 47)+1;
               i:= trunc((windowy-5) div 13)+1;
            end;
     
     
     end; { case } 
  
  
  end;  { Nextij }
                   

begin
   i:= 2; j:= 1;
   tint:= t;
   lil:= libl;
   lic:= libc;
   Cadre;
   Tableau;
   repeat
      begin
         if j=1 then Getlibl;
         if i=1 then Getlibc;
         if (i>1) and (j>1) then Getcase;
         Nextij;
      end;
   until valid= true;
   ok;
end;
         

    procedure egal (tab1 : tab; var tab2:tabr);
       var i,j: integer;
       begin
          for i:= 1 to m do
             begin
                for j:= 1 to n do
                   begin
                      tab2[i,j]:= tab1[i,J] + 0.0;
                   end;
             end;
   end;
                    
FUNCTION TOTAL (TABL:tabr):REAL;
VAR TOTA:REAL; i,j:integer;
BEGIN
        TOTA:=0.0;
        FOR I:=1 TO M DO
          BEGIN
          FOR J:= 1 TO N DO
            BEGIN
            TOTA:= TOTA+ TABL [I,J];
            END;
          END;
TOTAL:=TOTA;
END;


procedure Calibrer;
   var
      i,j,b: integer;
      a: real;
      
   begin
      Cadre;
      fillchar(t0,sizeof(t0),0);
      egal(t,t0);
      a:= Total(t0);
      moveto(20,40);
      drawtext('Le tableau actuellement en memoire comporte ');
      Dessint(m*n);
      drawtext(  ' cases.');
      moveto(20,55);
      drawtext('Le total des effectifs contenus dans ces cases est de : ');
      Dessreel(a);
      moveto(20,70);
      drawtext('Vous pouvez modifier ce total et de ce fait modifier ');
      moveto (20,85);
      drawtext('proportionnellement l effectif de chaque case.');
      moveto (20,120);
      drawtext('Donnez le nouveau total du tableau actuel (0/32766) : ');
      repeat
         begin
            moveto(320,120);
            drawtext('               ');
            annul:= false; tempo:= '';
            Input (320,120,26,W3,4,2,tempo);
            if annul= true then 
               begin
                  Annuler;
                  Sortir(W3);
               end;
         end;
      until (Test(tempo)= true) and (strint(tempo)<maxint) and (strint
      (tempo)>= 0);
      b:= strint(tempo);
      Valider;
      
      for i:= 1 to m do
          begin
            for j:= 1 to n do
                    begin
                       t[i,j]:= round (t0[i,j]*b/a);
                    end;
           end;
           
      calc:= false;
         
      Sortir(W3);
   end;
    
PROCEDURE CORRESPONDANCES;
    
    var
       i,j,r,it:integer;
       te,ar1,ar2:real;
       tt: tabr;
    


        


FUNCTION KHI2 (TABL,TABLREF:tabr):REAL;
VAR KH:REAL;
BEGIN
KH:=0;
FOR I:= 1 TO M DO
        BEGIN
           FOR J:= 1 TO N DO
              begin
                 KH:= KH + TABL[I,J] * TABL [I,J] / TABLREF [I,J];
              end;
        END;
KHI2:=KH;
END;
        
        
        
        
PROCEDURE MARGEL (TABL:tabr ; VAR VECTL:VECL);

BEGIN 
fillchar(vectl,sizeof(vectl),0);
FOR I:= 1 TO N DO
        BEGIN
        FOR J:= 1 TO M DO
        BEGIN
        VECTL [I]:= VECTL [I] + TABL [J,I];
        END;
        END;
        
END;


PROCEDURE MARGEC (TABL:tabr; VAR VECTC:VECC);

BEGIN
fillchar(vectc,sizeof(vectc),0);
FOR I:= 1 TO M DO
        BEGIN
        FOR J:= 1 TO N DO
                BEGIN
                VECTC [I] := VECTC [I] + TABL [I,J];
                END;
        END;
END;


PROCEDURE RECONST (VECTL:VECL ; VECTC:VECC ; TOT : REAL ;VAR TABL:tabr);

BEGIN
FOR I:= 1 TO M DO
        BEGIN
        FOR J:= 1 TO N DO
        TABL [I,J] := VECTL [J] * VECTC [I] / TOT;
        END;
END;


PROCEDURE SOUSTRAC ( TABL1,TABL2 :tabr ; VAR TABL:tabr );
        
BEGIN 
FOR I:= 1 TO M DO
        BEGIN
        FOR J:= 1 TO N DO
        TABL [I,J] := TABL1 [I,J] - TABL2 [I,J];
        END;
END;



PROCEDURE TABARRON (VAR TABL:tabr);

BEGIN 
FOR I:= 1 TO M DO
        BEGIN
        FOR J:= 1 TO N DO
        ARRONDI ( TABL[I,J] );
        END;
END;



FUNCTION LAMBDA ( VECT1,VECT2 :VECL ):REAL;

VAR
L:REAL;
BEGIN
L:=0;
FOR I:= 1 TO N DO
BEGIN
L:=L+ ( VECT1 [I] * VECT2 [I] );
END;
LAMBDA:=SQRT (L);
END;


FUNCTION LAMBDAC (VECT1,VECT2: VECC ):REAL;

VAR L:REAL;
BEGIN
L:=0;
FOR I:= 1 TO M DO
        BEGIN
        L:= L+ (VECT1 [I] *VECT2 [I]);
        END;
LAMBDAC := SQRT (L);
END;



PROCEDURE VDEPART (TABL:tabr;VAR VECTC:VECC);
 
 BEGIN
 J:=1; 
 FOR I:= 1 TO M DO
        BEGIN
        IF TABL [I,J] >=0 THEN VECTC[I] := 1
        ELSE VECTC [I] := -1;
        END;
 END;


PROCEDURE CALNVL (TABL:tabr; VECTC:VECC; VAR VECT:VECL);

BEGIN
fillchar(vect,sizeof(vect),0);
FOR I:= 1 TO N DO
        BEGIN
        FOR J:= 1 TO M DO
        VECT [I] := VECT [I] + TABL [J,I] * VECTC [J]; 
        END;
END;
        

PROCEDURE LPOND (VECTL1,VECTL2:VECL; VAR VECTL3:VECL);

BEGIN
FOR I:= 1 TO N DO
VECTL3 [I] :=( VECTL1 [I] / VECTL2 [I]) ;
END;
        

PROCEDURE LREDUC (VECTL :VECL; L:REAL; VAR VECTL1:VECL);

BEGIN
FOR I:= 1 TO N DO
VECTL1[I] := VECTL [I] / L;
END;


PROCEDURE CALNVC (TABL:tabr; VECTL:VECL; VAR VECTC:VECC);

BEGIN
fillchar(vectc,sizeof(vectc),0);
FOR I:= 1 TO M DO
        BEGIN
        FOR J:= 1 TO N DO
        VECTC [I] := VECTC[I] +VECTL [J] * TABL [I,J];
        END;
END;


PROCEDURE CPOND (VECTC1,VECTC2:VECC; VAR VECTC3:VECC);

BEGIN
FOR I:= 1 TO M DO
VECTC3[I]:=( VECTC1[I] / VECTC2 [I]);
END;


PROCEDURE CREDUC (VECTC:VECC; L:REAL; VAR VECTC1:VECC);

BEGIN
FOR I:= 1 TO M DO
VECTC1[I] := VECTC [I] / L;
END;


PROCEDURE INIT;

BEGIN

fillchar(vlc,sizeof(vlc),0);
fillchar(vlcp,sizeof(vlcp),0);
fillchar(vlr,sizeof(vlr),0);
fillchar(vlrp,sizeof(vlrp),0);
fillchar(nvlc,sizeof(nvlc),0);
fillchar(nvlcp,sizeof(nvlcp),0);
fillchar(nvlr,sizeof(nvlr),0);
fillchar(nvlrp,sizeof(nvlrp),0);

fillchar(vcc,sizeof(vcc),0);
fillchar(vccp,sizeof(vccp),0);
fillchar(vcr,sizeof(vcr),0);
fillchar(vcrp,sizeof(vcrp),0);
fillchar(nvcc,sizeof(nvcc),0);
fillchar(nvcr,sizeof(nvcr),0);
fillchar(nvccp,sizeof(nvccp),0);
fillchar(nvcrp,sizeof(nvcrp),0);

END;

PROCEDURE RESULTAT;

var i,j,k,d: 0..255; max: real;
vl1,vl2: vecc; vc1,vc2: vecl;

procedure axes;
begin
   moveto(260,10);
   line(0,120);
   moveto(20,70);
   line(480,0);
end;

PROCEDURE semicalibrage;
   BEGIN
      for i:= 1 to n do
      vl1[i]:= vl1[i] / (sqrt(lb[1]));
      for i:= 1 to m do
      vc1[i]:= vc1[i] / (sqrt(lb[1]));
      for i:= 1 to n do
      vl2[i]:= vl2[i] / (sqrt(lb[2]));
      for i:= 1 to m do
      vc2[i]:= vc2[i] / (sqrt(lb[2]));
   END;
   
   
PROCEDURE MAXI;

BEGIN
MAX:= 0;
FOR I:= 1 TO M  DO 
        BEGIN
        IF ABS (VC1[I] ) > MAX THEN MAX := ABS (VC1[I]);
        IF ABS (VC2[I]) > MAX THEN MAX := ABS (VC2[I]);
        END;
FOR I:= 1 TO N DO
        BEGIN
        IF ABS (VL1[I]) > MAX THEN MAX:= ABS(VL1[I]);
        IF ABS (VL2[I]) > MAX THEN MAX := ABS (VL2[I]);
        END;
FOR I:= 1 TO M DO 
        BEGIN
        VC1[I] := VC1[I] / MAX * 240;
        VC2[I] := VC2[I] / MAX * 75;
        END;
FOR I:= 1 TO N DO
        BEGIN
        VL1[I] := VL1[I] / MAX * 240;
        VL2[I] := VL2[I] / MAX * 75;
        END;
END;


procedure Trace;
   begin
      Axes;
      ObscureCursor;
      for i:= 1 to m do
         begin
            moveto(260,70);
            lineto (260+round(vc1[i]),70-round(vc2[i]));
            drawtext(libl[i]);
         end;
      for i:= 1 to n do
         begin
            moveto(260,70);
            lineto (260+round(vl1[i]),70-round(vl2[i]));
            drawtext(libc[i]);
         end;
      ShowCursor;
   end;
   
procedure Chiffres;
   const
      plan= '  PLAN  DES  FACTEURS  1  ET  2  ';
   var
      r3:rect;
   begin
      MakeRect(r3,15,130,515,157);
      FrameRect(r3);
      moveto(160,145);
      drawtext(PLAN );
      moveto(160,145);line(Textwidth(plan),0);
      moveto(100,155);
      drawtext('KHI2 Total = ');Dessreel (khit);
      drawtext('        ');
      drawtext('AXE 1 : ');Dessint(round(100*(khi[1]/khit)));
      drawtext(' %        ');
      Drawtext('AXE 2 : ');Dessint(round(100*(khi[2]/khit)));
      drawtext(' % ');
   end;
   
      
begin { resultat }
   vl1:= vl[1]; vl2:= vl[2]; vc1:= vc[1]; vc2:= vc[2];
   Semicalibrage;
   moveto (10,100);
   Maxi;
   Trace;
   Chiffres;
END;


Function TestMarges: boolean;
   begin
      TestMarges:= true;
      for i:= 1 to m do
      if mac[i] = 0 then TestMarges:= false;
      for i:= 1 to n do
      if mal[i] = 0 then TestMarges:= false;
   end;
   
   
procedure Indep;
   begin
      moveto (20,80);
      for i:= 1 to 2 do
      drawtext('                                  ');
      moveto(20,80);
      drawtext('Tableau Independant. Khi2 = ');
      DessInt (round(khit));
      exit(Correspondances);
   end;

        
BEGIN  {  correspondances  }


if calc= true then
   begin
      Resultat;
      exit(Correspondances);
   end;
INIT;
fillchar(t0,sizeof(t0),0);
fillchar(reste,sizeof(reste),0);
fillchar(tt,sizeof(tt),0);
egal(t,tt);

margel(tt,mal);margec(tt,mac);
if TestMarges= false then 
   begin
      moveto (20,80);
      Drawtext('Desole... vos  donnees  sont  incorrectes');
      exit(Correspondances);
   end;
   
moveto (20,80);drawtext ('Un petit moment s il vous plait .'); 
te:= total(tt);
drawtext(' .');
RECONST (MAL,MAC,TE,T0);
{ TABARRON (T0); }
drawtext(' .');
Soustrac(tt,t0,reste);
{TABARRON (RESTE); }
KHIT := KHI2 (RESTE,T0);
if khit<=5  then Indep;
{ if khit>=32767 then
   begin
      moveto(20,80);
      for i:= 1 to 10 do
      drawtext('       ');
      moveto(20,80);
      drawtext('Desole... le Khi2 est trop grand ( > 32766 )');
      exit(Correspondances);
   end; }
drawtext(' .');
for r:= 1 to 2 do
        BEGIN
            Drawtext(' .');
            VDEPART (RESTE,NVCC);
            CALNVL (RESTE,NVCC,NVLC);
            LPOND (NVLC,MAL,NVLCP);
            LB[R]:= LAMBDA (NVLC,NVLCP);
            if lb[r] =0 then Indep;
            drawtext(' .');
            LREDUC (NVLC,LB[R],NVLR);
            LREDUC (NVLCP,LB[R],NVLRP);
            IT:=1;
            REPEAT 
                    BEGIN
                        drawtext(' .');
                        VCC:=NVCC;VCCP:=NVCCP;VCR:=NVCR;VCRP:=NVCRP;
                        CALNVC (RESTE,NVLRP,NVCC);
                        CPOND (NVCC,MAC,NVCCP);
                        LB[R] := LAMBDAC (NVCC,NVCCP);  
                        if lb[r] = 0 then Indep;
                        drawtext(' .');
                        CREDUC (NVCC,LB[R],NVCR);
                        CREDUC (NVCCP,LB[R],NVCRP);
                        VLC:=NVLC;VLCP:=NVLCP;VLR:=NVLR;VLRP:=NVLRP;
                        CALNVL (RESTE,NVCRP,NVLC);
                        LPOND (NVLC,MAL,NVLCP);
                        LREDUC (NVLC,LB[R],NVLR);
                        LREDUC (NVLCP,LB[R],NVLRP);
                        AR1:= NVLR[1] *100 ; AR2:= VLR[1]* 100;
                        ARRONDI (AR1);ARRONDI (AR2);IT:=IT+1;
                    END;
            UNTIL (AR1=AR2) OR (IT > 3 );
            
            WRITELN ('VLRP 1,1 = ',NVLRP[1]);
            RECONST (NVLC,NVCC,LB[R],TA[R]);TT:= TA[R];
            drawtext(' .');
            { TABARRON (TA[R]); }
            KHI[R] :=KHI2(TA[R],T0);
            drawtext(' .');
                    
            VL[R]:=NVLC;
            VC[R]:=NVCC;
            drawtext(' .');
            SOUSTRAC (RESTE,TA[R],RESTE);
            {TABARRON (RESTE);}
            INIT;
        END; { for }
  moveto (20,80);
  for i:= 1 to 2 do
  drawtext('                                       ');
  Resultat;
  calc:= true;
        
END;   { Corresp. }
                

procedure Catalog;
   begin
      InitRect;
      reset(pile,'TK:fichier');
      for i:= 1 to 5 do
         begin
            seek(pile,i);
            get(pile);
            element:= pile^;
            moveto(40,5+12*i);
            Dessint(i);moveto(60,5+12*i);drawtext(' :  ');
            framerect(ca[i]);
            if length (element.titre)>0 then 
               begin
                  moveto(75,5+12*i);
                  drawtext(element.titre);
               end;
         end;
         for i:= 1 to 5 do
         begin
            seek(pile,i+5);
            get(pile);
            element:= pile^;
            moveto(270,5+12*i);
            Dessint(i+5);moveto(290,5+12*i);drawtext(' :  ');
            framerect(ca[5+i]);
            if length(element.titre)>0 then 
               begin
                  moveto(305,5+12*i);
                  drawtext(element.titre);
               end;
         end;
      close(pile,lock);
   end;

procedure Allume (lequel: integer);
   begin
      paintrect (ca[lequel]);
      SetTextBG(0);
      if lequel < 6 then
         begin
            moveto(40,5+12*lequel);
            Dessint(lequel);
         end
         else
            begin
               moveto(270,5+12*(lequel-5));
               Dessint(lequel);
            end;
      SetTextBG(127);
   end;
   
procedure Eteint (lequel: integer);
   begin
      fillchar(p1,sizeof(p1),255);
      SetPattern (p1);
      paintrect (ca[lequel]);
      fillchar(p1,sizeof(p1),0);
      SetPattern(p1);
      if lequel < 6 then
         begin
            moveto(40,5+12*lequel);
            Dessint(lequel);
            framerect(ca[lequel]);
         end
         else
            begin
               moveto(270,5+12*(lequel-5));
               Dessint (lequel);
               framerect(ca[lequel]);
            end;
   end;
   

procedure SelectCarre (fen: integer);
   var
      val: boolean;
      
   procedure SetCarre (choix:integer);
      begin
         if carre= 0 then
            begin
               carre:= choix;
               Allume(choix);
            end
         else
         if carre= choix then val:= true
         else
            begin
               Eteint (carre);
               carre:= choix;
               Allume(choix);
            end;
     end;
      
   begin
      carre:= 0;
      val:= false;
      repeat
         begin
            repeat
               begin
                  GetEvent (event);
               end;
            until event.evt_kind= button_down;
            with event do
               begin
                  screenx:= char1+ 256*char2;
                  screeny:= char3+ 256*char4;
                  ScreenToWindow (fen,screenx,screeny,windowx,windowy);
               end;
                  
            moveto(windowx,windowy);
            if Inrect(ca[1]) then SetCarre(1) else
            if Inrect(ca[2]) then SetCarre(2) else
            if Inrect(ca[3]) then SetCarre(3) else
            if Inrect(ca[4]) then SetCarre(4) else
            if Inrect(ca[5]) then SetCarre(5) else
            if Inrect(ca[6]) then SetCarre(6) else
            if Inrect(ca[7]) then SetCarre(7) else
            if Inrect(ca[8]) then SetCarre(8) else
            if Inrect(ca[9]) then SetCarre(9) else
            if Inrect(ca[10]) then SetCarre(10) else
            
            if Inrect(r) then
               begin
                  Annuler;
                  Sortir(fen);
               end else
            
            if Inrect(r1) then
               begin
                  if carre= 0 then SoundBell
                  else  val:= true;
               end;
         
         end;
      until val=true;
   end; { Select }
            

procedure Charge;
   begin
     Cadre;
     Catalog;
     moveto(25,100);
     drawtext('Clickez  le  Numero  du  Tableau  a  Charger.');
     SelectCarre(W8);
     moveto(180,115);
     Valider;
     reset (pile,'TK:fichier');
     seek(pile, carre);
     get(pile);
     element:= pile^;
     
     with element do
        begin
           if length(titre)>0 then 
              begin
                 moveto(75,115);
                 drawtext('Tableau  ');
                 drawtext(titre);
                 drawtext('  charge');
              end;
           m:= nblig; n:= nbcol;
           for i:= 1 to m do
              begin
                 libl[i]:= ldata[i];
              end;
           for i:= 1 to n do
              begin
                 libc[i]:= cdata[i];
              end;
           for i:= 1 to m do
              begin
                 for j:= 1 to n do
                    begin
                       t[i,j]:= data[i,j];
                    end;
              end;
        end;
     close(pile,lock);
     Sortir(W8);
  end;
  
  
  
procedure Sauve;
   begin
      Cadre;
      Catalog;
      moveto(25,100);
      drawtext('Sauver sous  quel  nom  : ');
      tempo:= '';
      annul:= false;
      Input(200,100,26,W9,12,1,Tempo);
      if annul= true then
         begin
            Annuler;
            Sortir(W9);
         end;
      moveto (25,115);
      drawtext('Clickez le Slot  ( 1 / 10 )  ');
      Selectcarre(W9);
      Valider;
      reset(pile,'TK:fichier');
      fillchar(element,sizeof(element),0);
      with element do
         begin
            nblig:= m; nbcol:= n;
            titre:= tempo;
            for i:= 1 to m do
               begin
                  ldata[i]:= libl[i];
               end;
            for i:= 1 to m do
               begin
                  cdata[i]:= libc[i];
               end;
            for i:= 1 to m do
               begin
                  for j:= 1 to n do
                     begin
                        data[i,j]:= t[i,j];
                     end;
               end;
         end; { with }
      seek(pile,carre);
      pile^:= element;
      put(pile);
      close(pile,lock);
      Sortir(W9);
   end;
   

procedure Apple;
   const intit= 'Analyse  des  Correspondances';
   begin
      moveto(20,14);
      drawtext(intit);
      moveto(20,14);
      line(TextWidth(intit),0);
      moveto(80,28);
      drawtext( 'ecrit par B.ZEITOUN');
      moveto (15,44);
      drawtext('representation des vecteurs');
      moveto(15,54);
      drawtext('non ponderes, semi-calaibres.');
      moveto(15,94);
      drawtext('clickez dans cette fenetre...');
   end;
   
   
         

    begin   {Drawit}
      case which_window of
        
          W1:
          begin
             moveto (10,10);
             drawtext('memoire disponible : ');
             DessInt (2* memavail);
             drawtext('  octets');
          end;
        
        W2: Entrer; 
               
        W3: Calibrer;
          
        W4: Tableau;
        
        W5: Modif;
        
        W6:Correspondances;
        
        W7: Catalog;
        
        W8:  Charge ;
        
        W9:  Sauve  ;
        
        W10: Apple;
          
      end; {case}
    
    end;



procedure  DrawItB  (which_window : integer);
    var
         p : pattern;
    begin
      GetWinPort(which_window,mainport);
      SetPort(mainport);
      DrawIt(which_window);
    end;


procedure  HandleUpdate     (which_window : integer);
        begin
          BeginUpdate(which_window);
          
          if IOResult <> 0 then 
            begin
              exit(HandleUpdate); 
            end;
          
          DrawIt(which_window);
          
          EndUpdate;
        end;



procedure  ClearUpdates;
    begin
      repeat
        PeekEvent(event);
        if event.evt_kind = update_event then
          begin
            GetEvent(event);
            HandleUpdate(event.char1);
          end;
      until event.evt_kind <> update_event;
    end;
    
    
   procedure InitMouseDriver;
      var
          {Mouse driver communications data}
          ErrorCode
            : integer;
          
          MouseMode: record
             IntMode: integer;
             IntAddr: integer;
             end;
             
          RequestCode: packed record
             Direction: 0..1;
             Stat_Ctrl: 0..1;
             Reserved: 0..2047;
             Code: 0..7;
             end;
       
      procedure InitInterrupts;
         begin { InitInterrupts }
            (*
            {Set the attach driver's interrupt address:
             UnitStatus Control code 0.}
            with RequestCode do
               begin
                  Direction:= 0;
                  Stat_Ctrl:= 1;
                  Code:= 0;
               end; { with }
            with MouseMode do
               begin
                  IntMode:= 0; { passive mode for now; if interrupts are
                                 required, StartDeskTop will enable them }
                  PascIntAdr(IntAddr);
               end; { with }
            UnitStatus(131, MouseMode, RequestCode);
            ErrorCode:= IOResult;
            if ErrorCode<> 0 then
               begin
                  WriteLn('SetMouse error: ', ErrorCode);
                  exit(psample);
               end; { if }
            *)
         end; { of InitInterrupts }
     
      begin { InitMouseDriver }
        {Start with the mouse off}
        UnitClear(131);
        ErrorCode:= IOResult;
        if ErrorCode<> 0 then
           begin
              if ErrorCode= 9 then
                 writeln('No mouse card installed.')
              else
                 writeln('UnitClear error: ', ErrorCode);
              exit(psample);
           end; { if }
     
        {InitInterrupts;}
        
     end; { of InitMouseDriver }
     
     
procedure StartItUp;
    begin { StartItUp }
       MouseSlot:= 0;
       use_interrupts:= false;
       pointer:= 4096;
       
       StartDeskTop(6, 234,         {Apple //c, Apple //e}
                    MouseSlot,      {search slots for the mouse}
                    use_interrupts, {passive= false; interrupts= true}
                    PtrToFont,      {pointer to system font}
                    pointer,        {menu save area}
                    4000);          {save area size}
                    
       SetKeyEvent(true);
       
       FlushEvents;
    
       SetMenu(a_menubar);
       ShowCursor;
    end; { of InitDeskTop }
    
      
      
procedure NewWindow(nextwindow: integer);
    var
        OldTop : integer;
    begin { NewWindow }
      FrontWindow(OldTop);
      if OldTop <> 0 then
         CheckItem(menu_id, OldTop, false);
      CheckItem(menu_id, menu_choice, true);
      OpenWindow(a_winfo[nextwindow]);
      
      DrawItB(menu_choice);
    end; { of NewWindow }
    
    
procedure DoMenu1;
   var
       event: type_event;
       screenx,screeny: integer;
       whicharea: type_area;
       windowid: integer;

   begin
      OpenWindow(a_winfo[W10]);
      DrawItB(W10);
      repeat
      begin
         getevent(event);
         if event.evt_kind= button_down then
            begin
               with event do
                  begin
                     screenx:= char1+ 256* char2;
                     screeny:= char3+ 256* char4;
                     FindWindow(screenx,screeny,whicharea,windowid);
                  end;
         end;
    end;
    until (event.evt_kind= button_down) and (whicharea= in_content)
       and(windowid= W10);
    
    CloseWindow(W10);
 end;
    
    
      
procedure DoMenu2;
    
    begin
       case menu_choice of
           1: begin
                 OpenWindow(a_winfo[W7]);
                 DrawItB (W7);
              end;
           
           2: begin
                 if m= 0 then 
                    begin
                       OpenWindow(a_winfo[W8]);
                       DrawItB (W8);
                    end;
              end;
             
           3: begin
                 if m>0 then
                    begin
                       OpenWindow(a_winfo[W9]);
                       DrawItB (W9);
                    end;
              end;
              
           4: exit(Psample);
       end;
 end;

procedure BringItUp (ThisOne : integer);
    begin
      FrontWindow(topwindow);
      if topwindow <> ThisOne then
         begin
            SelectWindow(ThisOne);
            DrawItB(ThisOne);
         end;
    end;
    
procedure DoContent;
   { This proc will do more when I do scrolling. }
   begin
      BringItUp(WindowID);
   end; { of DoContent }

         
procedure DoDrag;
    var
        ItMoved : boolean;
    begin
      DragWindow(windowid, screenx, screeny,ItMoved);
      
      if ItMoved then
          Clear_Updates;
    end;

procedure DoGrow;
    var
       ItGrew : boolean;
    begin
      GrowWindow(windowid, screenx, screeny,ItGrew);
    end;
    
procedure DoHide;
    var
       NewTop : integer;
       
    begin
      CloseWindow(windowid);
      FrontWindow(NewTop);
      if NewTop <> 0 then 
    end; 
    
    
procedure DoMenu3;
begin
   case menu_choice of
      
      1: begin
            OpenWindow (a_winfo [W1]);
            DrawItB (W1);
         end;
      
      2: begin
            if m>0 then
               begin
                  OpenWindow (a_winfo[W4]);
                  DrawItB (W4);
               end;
         end;
         
      3: begin
            if m>0 then 
               begin
                  OpenWindow (a_winfo[W6]);
                  DrawItB (W6);
               end;
         end;
   end; {case }
end;
         
procedure DoMenu4;
   begin
      case menu_choice of
      
         1: Begin
               DoVide;
               CloseAll;
            end;
            
         2:begin 
              if m= 0 then
                 begin
                    OpenWindow (a_winfo [W2]);
                    DrawItB (W2);
                 end; 
           end;
           
         3:begin 
              if m>0 then
                 begin
                    OpenWindow(a_winfo[W5]);
                    DrawItB (W5);
                 end;
           end;
           
         4:begin 
              if m>0 then
                 begin
                    OpenWindow(a_winfo[W3]);
                    DrawItB (W3);
                 end;
           end;
           
      end; {case }
   end;
    
procedure doMenu;
    begin { doMenu }
      if menu_id in [menu1,menu2,menu3,menu4] then
        case menu_id of
           Menu1: DoMenu1;
           Menu2 : DoMenu2;
           Menu3: Domenu3;
           Menu4: Domenu4;
        end
      else exit(DoMenu);
      HiliteMenu(0); 
    end; { of doMenu }

procedure HandleButton;
    begin { HandleButton }
      with event do
        begin
          screenx:= char1+ 256* char2;
          screeny:= char3+ 256* char4;
          FindWindow(screenx, screeny, whicharea, windowid);
          case whicharea of
            
            inMenubar: 
              begin
                MenuSelect(menu_id, menu_choice);
                doMenu;
              end; { case inMenubar }
            
            inDrag: 
              begin
                BringItUp(WindowID);
                DoDrag; 
              end;
            
            inGrow: DoGrow;
              
            inGoAway: 
              begin
                TrackGoAway(DoGoAway);
                if DoGoAway then DoHide;
              end;
             
            inContent: DoContent;
         
          end; { case }
        end; { with }
    end; { of HandleButton }


begin { psample }
   
   Initialize;
   InitMouseDriver;
   StartItUp;
   SetKeyEvent (true);
   
   InitPort(MainPort);
   SetPort(MainPort);
   DoVide;
   {SignOn;}
   
   
   QuitSelected:= false;
   Repeat
      GetEvent(event);
      
      if event.evt_kind in [ButtonDown,KeyDown,UpdateEvent] then 
        case event.evt_kind of
           button_down : HandleButton;
           update_event : HandleUpdate(event.char1);
           
        end;
   
   Until QuitSelected;
   CloseAll;

end. { of psample }

