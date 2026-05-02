import { forwardRef, InputHTMLAttributes } from 'react';

// InputProps extends InputHTMLAttributes<HTMLInputElement> directly

const Input = forwardRef<HTMLInputElement, InputHTMLAttributes<HTMLInputElement>>(
  ({ className, style, ...props }, ref) => {
    const inputStyle = {
      width: '100%',
      padding: '12px 16px',
      borderRadius: 12,
      border: '1.5px solid #E8DDD5',
      background: '#fff',
      fontSize: 16,
      fontFamily: "'DM Sans', sans-serif",
      color: '#3D2B1F',
      transition: 'all 0.18s',
      ...style,
    };

    return (
      <input
        className={className}
        style={inputStyle}
        ref={ref}
        {...props}
      />
    );
  }
);

Input.displayName = 'Input';

export { Input };