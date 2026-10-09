1;
% Dados iniciais (Arbitrários):
% Vcc, Ic, Hfe
% Fc_low, Fc_high
%
% Elementos a definir:
% Impedancias (Zin, Zout)
% Ganho
% Resistências (Rc, Re, R1, R2) -> polarização
% Capacitores (C1, C2, C3) -> Passa banda e acoplamento

% Informações sobre o dispositivo da yamaha:
% https://audio-database.com/YAMAHA/speaker/ns-1000m.html -> frequencia de crossover (vulgo frequência de corte): 500 Hz, 6 kHz, 12dB/oct.
% Ou seja, os médios vão de 500 Hz até 6 kHz, caindo 12dB por oitava após a frequência de corte

% Ao polarizar um BJT deseja-se manter o ponto Q independente de parâmetros externos
% Para isso devemos minimizar o efeito de Bcc (Hfe) da seguinte forma: R2 <= 0.01*Bcc*Re
% Porém essa configuração deixa a impedância de entrada do circuito muito baixa
% Para resolver utilizamos: R2 <= 0.1*Bcc*Re
% Bcc é o menor valor possível do BJT

global paralelo = @(r1, r2) (r1*r2)/(r1+r2);
global Xc = @(C, f) 1/(2*pi*f*C);
global capacitor_corte = @(fc, r) 1/(2*pi*fc*r);

% Polarização do BJT, aproximando Ie = Ic;
function [R1, R2, Rc, Re] = analiseDC(Vcc, Ic, Hfe, Bcc)
  % Tensões ao redor do BJT
  Vc = 0.5*Vcc;
  Ve = 0.1*Vcc;
  Vb = Ve + 0.7;
  % Calculo dos Resistores
  Rc = (Vcc-Vc-Ve)/Ic;
  Re = Ve/Ic;      % considerando Ie = Ic
  R2 = 0.1*Bcc*Re; % não sei se deixo assim ou se boto Hfe direto 
  R1 = ((R2*Vcc)/Vb) - R2;
  
  printf("\n=== RESULTADOS DC ===\n");
  printf("Ib: %.2e\n", Ic/Hfe);
  printf("Resistores:\n");
  printf("Rc: %.2f\n", Rc);
  printf("Re: %.2f\n", Re);
  printf("R1: %.2f\n", R1);
  printf("R2: %.2f\n", R2);
  printf("Tensões:\n");
  printf("Vc:  %.2e\n", Vc);
  printf("Ve:  %.2e\n", Ve);
  printf("Vb:  %.2e\n", Vb);
end

% Definição dos capacitores nas frequencias de corte 500 Hz e 6 kHz
% E analise das impedâncias e ganho
% Zin e Zout são funções
function [C1, C2, C3, Zin, Zout] = analiseAC(Vcc, Ic, Hfe, Vt, Fc_low, Fc_high, R1, R2, Re, Rc, Rl)
  % C1 é o passa faixa na entrada do BJT
  re = Vt/Ic;
  req = paralelo(paralelo(R1, R2), Hfe*(Re+re)); % paraleo das resistencias da entrada
  C1 = capacitor_corte(Fc_low, req);
  C2 = capacitor_corte(Fc_high, Rc); % apenas o Rc participa da conta para o passa baixa na saida
  C3 = capacitor_corte(0.1*Fc_low, Rl); % Capacitor de acoplamento, forma um passa baixa com o Rl

  Zin  = @(f) Xc(C1, f) + req;
  Zout = @(f) paralelo(Xc(C2, f), Rc);
  A    = @(f) -(Zout(f)/Re);

  fq = 20:20000;
  plot(fq, Zin, fq, Zout, fq, A);
  legend("Zin", "Zout", "ganho")
end





Ic       = input("Insira a corrente (em A):\n> ");
B        = input("Insira o betinha:\n> ");
Vcc      = input("Insira a tensão (em V):\n> ");
Vt       = input("Insira Vt (em V):\n> ")
Fc_low   = input("Insira a menor frequência (em Hz):\n> ")
Fc_high  = input("Insira a maior frequência (em Hz):\n> ")
printf("==== Vcc = %.2e | Ic = %.2e | Hfe = %.2e ====\n", Vcc, Ic, B);
[R1, R2, Rc, Re] = analiseDC(Vcc, Ic, B)
[C1, C2, C3, Zin, Zout] = analiseAC(Vcc, Ic, B, Vt, Fc_low, Fc_high, R1, R2, Re, Rc, Rl)
