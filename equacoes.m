
divisor_tensao = @(r1, r2, vin) (vin*r1)/(r1+r2);
r_paralelo = @(r1, r2) (r1*r2)/(r1+r2);

Vc = @(Vcc) 0.5*Vcc;
Ve = @(Vcc) 0.1*Vcc;
Vb = @(Vcc) Ve(Vcc)+0.7;

Ib = @(Ic, B) Ic/B;
Ie = @(Ic, B) Ib(Ic, B) + Ic;
%IC é arbitrario

Rc = @(Vcc,Ic) (Vcc-Vc(Vcc)-Ve(Vcc))/Ic;
Re = @(Vcc, Ic, B) Ve(Vcc)/Ie(Ic, B); 
R2 = @(Vcc, Ic, B) 0.1*B*Re(Vcc, Ic, B);
R1 = @(Vcc, Ic, B) (R2(Vcc, Ic, B)*(Vcc - Vb(Vcc)))/B;



function polarizacao(Vcc, Ic, B, vc, ve, vb, ie, ib, rc, re, r1, r2)

  printf("==== RESULTADOS ====\n");
  printf("==== Vcc = %.2e | Ic = %.2e | betinha = %.2e ====\n", Vcc, Ic, B);
  printf("==== Tensões ====\n");
  printf("Vcc: %.2E\n", Vcc);
  printf("Vc: %.2E\n", vc);
  printf("Ve: %.2E\n", ve);
  printf("Vb: %.2E\n", vb);
  printf("\n==== Correntes ====\n");
  printf("Ic: %.2E\n", Ic);
  printf("Ie: %.2E\n", ie);
  printf("Ib: %.2E\n", ib);
  printf("\n==== Resistores ====\n");
  printf("Rc: %.2f\n", rc);
  printf("Re: %.2f\n", re);
  printf("R1: %.2f\n", r1);
  printf("R2: %.2f\n", r2);
end


Ic  = input("Insira a corrente:\n> ")
B   = input("Insira o betinha:\n> ")
Vcc = input("Insira a tensão:\n> ")
polarizacao(Vcc, Ic, B, Vc(Vcc), Ve(Vcc), Vb(Vcc), Ie(Ic, B), Ib(Ic, B), Rc(Vcc, Ic), Re(Vcc, Ic, B), R1(Vcc, Ic, B), R2(Vcc, Ic, B));
