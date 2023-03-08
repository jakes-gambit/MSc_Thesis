function [c,ceq] = altarot(lam, u11, u12, u13, u21, u22, u23, u31, u32, u33)

U3 = [u13, u23, u33]';
U1 = [u11, u21, u31]';
U2 = [u12, u22, u32]';

l1 = lam(:,1);


c = [];


%orthogonality conditions
ceq(1) = U1'*U1-1;
ceq(2) = U2'*U2-1;
ceq(3) = U3'*U3-1;
ceq(4) = U1'*U2;
ceq(5) = U1'*U3;
ceq(6) = U2'*U3;

%interpretation type conditions
ceq(7) = U2'*l1;
ceq(8) = U3'*l1;
end