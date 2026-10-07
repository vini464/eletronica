1;

function [c1] = cinput(r1, r2, re, Ic, Hfe, fc)
    rpi = (Hfe+1) * ((26*1e-3)/Ic);
    req = rpi + re;
    req = (req*r2)/(req+r2);
    req = (req*r1)/(req+r1);
    c1 = 1/(2*pi*req*fc);
end

function [c2] = coutput(rc, r3, fc)
    c2 = 1/(2*pi*rc*r3*fc);
end

function [r1, r2, rc, re, vc, ve, vb] = BJTpol(Ic, Vcc, Hfe)
    vc = 0.5*Vcc;
    ve = 0.1*Vcc;
    vb = ve+0.7;
    re = ve/Ic;
    rc = ((Vcc-vc)/Ic)-re;
    r2 = 0.1*Hfe*re;
    r1 = ((r2*Vcc)/vb) -r2;
end

function [av] = gain(in, out)
    av = 20*log10(out/in);
end

function showresult(Ic, Vcc, Hfe, r3, fc1, fc2)
    [r1, r2, rc, re, vc, ve, vb] = BJTpol(Ic, Vcc, Hfe);
    printf("\n\n=== Para Beta: %d\n", Hfe);
    printf("R1 = %.2f\t R2 = %.2f\n", r1,r2)
    printf("Re = %.2f\t Rc = %.2f\n", re, rc)
    printf("Ve = %.3E\t Vc = %.3E\t Vb = %.3E\n", ve, vc, vb)
    printf("\ncapacitores:\n")
    c1 = cinput(r1, r2, re, Ic, Hfe, fc2);
    printf("C1 = %.3E\n", c1);
    c2 =  coutput(rc, r3, fc1);
    printf("C2 = %.3E\n", c2);
end




Ic = 2*1e-3;
Vcc = 10;

Hfe1 = 110;
Hfe2 = 200;
Hfe3 = 420;

r3 = 100;
fc1 = 250;
fc2 = 4*1e3;

showresult(Ic, Vcc, Hfe1, r3, fc1, fc2);
showresult(Ic, Vcc, Hfe2, r3, fc1, fc2);
showresult(Ic, Vcc, Hfe3, r3, fc1, fc2);