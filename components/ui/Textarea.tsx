import { forwardRef, TextareaHTMLAttributes } from 'react';

// TextareaProps extends TextareaHTMLAttributes<HTMLTextAreaElement> directly

const Textarea = forwardRef<HTMLTextAreaElement, TextareaHTMLAttributes<HTMLTextAreaElement>>(
  ({ className, style, ...props }, ref) => {
    const textareaStyle = {
      width: '100%',
      minHeight: 80,
      padding: '12px 16px',
      borderRadius: 12,
      border: '1.5px solid #E8DDD5',
      background: '#fff',
      fontSize: 16,
      fontFamily: "'DM Sans', sans-serif",
      color: '#3D2B1F',
      resize: 'vertical' as const,
      transition: 'all 0.18s',
      ...style,
    };

    return (
      <textarea
        className={className}
        style={textareaStyle}
        ref={ref}
        {...props}
      />
    );
  }
);

Textarea.displayName = 'Textarea';

export { Textarea };