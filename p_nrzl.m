function p_nrzl( bitstream )
    %P_NRZL Polar Non-Return-to-Zero Level
    %   sample data:
    %       d = [ 0 1 0 0 1 1 0 0 0 1 1 ]
    %   usage:
    %       p_nrzl(d)
    %   author:
    %       Anastasios Latsas

    % pulse height
    pulse = 5;

    for bit = 1:length(bitstream)
        % set bit time
        bt = bit-1:0.001:bit;

        if bitstream(bit) == 0
            % low level pulse
            y = -(bt<bit) * pulse;
        else
            % high level pulse
            y = (bt<bit) * pulse;
        end

        try
            if bitstream(bit+1) == 1
                y(end) = pulse;
            else
                y(end) = -pulse;
            end
        catch e
            % bitstream end, assume next bit is 1
            y(end) = pulse;
        end

        % draw pulse and label
        plot(bt, y, 'LineWidth', 2);
        text(bit-0.5, pulse+2, num2str(bitstream(bit)), ...
            'FontWeight', 'bold')
        hold on;
    end
    % draw grid
    grid on;
    axis([0 length(bitstream) -pulse*2 pulse*2]);
    set(gca,'YTick', [-pulse 0 pulse])
    set(gca,'XTick', 1:length(bitstream))
    set(gca,'XTickLabel', '')
    title('Polar Non-Return-to-Zero Level')
end
