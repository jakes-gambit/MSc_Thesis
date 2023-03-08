function [ob] = obj_altavilla(F_pre, u13, u23, u33)

U3 = [u13, u23, u33]';
ob= U3'*(F_pre'*F_pre)*U3;
end