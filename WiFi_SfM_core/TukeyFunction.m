function [y] = TukeyFunction(x, b)

if (abs(x) <= b)
    y = (1 - ((x^2) / (b^2)))^2;
else
    y = 0;
end

end

