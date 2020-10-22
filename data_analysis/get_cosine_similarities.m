function sim = get_cosine_similarities(im,am)
    if nargin == 1
        sim = (im'*im)./(vecnorm(im)'*vecnorm(im));
    elseif nargin == 2
        sim = (im'*am)./(vecnorm(im)'*vecnorm(am));
    end
end