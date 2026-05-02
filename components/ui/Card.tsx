"use client";

import { HTMLAttributes, forwardRef, useState } from 'react';
import { T } from '@/lib/theme';

interface CardProps extends HTMLAttributes<HTMLDivElement> {
  hover?: boolean;
  dim?: boolean;
}

const Card = forwardRef<HTMLDivElement, CardProps>(
  ({ className, hover = true, dim = false, style, ...props }, ref) => {
    const [hovered, setHovered] = useState(false);

    const cardStyle = {
      background: dim ? '#F7F2ED' : '#fff',
      borderRadius: 20,
      border: `1.5px solid ${hovered && !dim ? T.orangeP : '#F0E8E0'}`,
      boxShadow: hovered && !dim ? '0 8px 32px rgba(61,43,31,0.10)' : '0 2px 10px rgba(61,43,31,0.06)',
      transition: 'all 0.22s',
      transform: hovered && !dim ? 'translateY(-2px)' : 'none',
      opacity: dim ? 0.75 : 1,
      ...style,
    };

    return (
      <div
        className={className}
        style={cardStyle}
        ref={ref}
        onMouseEnter={() => hover && setHovered(true)}
        onMouseLeave={() => hover && setHovered(false)}
        {...props}
      />
    );
  }
);

Card.displayName = 'Card';

const CardHeader = forwardRef<HTMLDivElement, HTMLAttributes<HTMLDivElement>>(
  ({ className, style, ...props }, ref) => {
    return (
      <div
        className={className}
        style={{ padding: 24, ...style }}
        ref={ref}
        {...props}
      />
    );
  }
);

CardHeader.displayName = 'CardHeader';

const CardTitle = forwardRef<HTMLHeadingElement, HTMLAttributes<HTMLHeadingElement>>(
  ({ className, style, ...props }, ref) => {
    return (
      <h3
        className={className}
        style={{
          fontFamily: "'Fraunces', serif",
          fontSize: 24,
          fontWeight: 700,
          color: T.brown,
          margin: 0,
          ...style,
        }}
        ref={ref}
        {...props}
      />
    );
  }
);

CardTitle.displayName = 'CardTitle';

const CardDescription = forwardRef<HTMLParagraphElement, HTMLAttributes<HTMLParagraphElement>>(
  ({ className, style, ...props }, ref) => {
    return (
      <p
        className={className}
        style={{
          fontSize: 16,
          color: T.brownM,
          margin: 0,
          marginTop: 8,
          lineHeight: 1.5,
          ...style,
        }}
        ref={ref}
        {...props}
      />
    );
  }
);

CardDescription.displayName = 'CardDescription';

const CardContent = forwardRef<HTMLDivElement, HTMLAttributes<HTMLDivElement>>(
  ({ className, style, ...props }, ref) => {
    return (
      <div
        className={className}
        style={{ padding: '0 24px 24px 24px', ...style }}
        ref={ref}
        {...props}
      />
    );
  }
);

CardContent.displayName = 'CardContent';

const CardFooter = forwardRef<HTMLDivElement, HTMLAttributes<HTMLDivElement>>(
  ({ className, style, ...props }, ref) => {
    return (
      <div
        className={className}
        style={{
          padding: '0 24px 24px 24px',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'flex-end',
          gap: 12,
          ...style,
        }}
        ref={ref}
        {...props}
      />
    );
  }
);

CardFooter.displayName = 'CardFooter';

export { Card, CardHeader, CardTitle, CardDescription, CardContent, CardFooter };