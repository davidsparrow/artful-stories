"use client";

import { ButtonHTMLAttributes, forwardRef } from 'react';
import { T } from '@/lib/theme';

type ButtonVariant = 'primary' | 'secondary' | 'outline' | 'ghost' | 'teal' | 'gold' | 'red';
type ButtonSize = 'sm' | 'md' | 'lg';

interface ButtonProps extends ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: ButtonVariant;
  size?: ButtonSize;
}

function getButtonStyles(variant: ButtonVariant = 'primary', size: ButtonSize = 'md', disabled = false, sx: any = {}) {
  const base = {
    border: 'none',
    cursor: disabled ? 'not-allowed' : 'pointer',
    fontFamily: "'DM Sans',sans-serif",
    fontWeight: 700,
    borderRadius: 12,
    transition: 'all 0.18s',
    display: 'inline-flex',
    alignItems: 'center',
    gap: 6,
    opacity: disabled ? 0.5 : 1,
    textDecoration: 'none',
  };

  const sizes = {
    sm: { padding: '7px 16px', fontSize: 13 },
    md: { padding: '11px 24px', fontSize: 15 },
    lg: { padding: '15px 32px', fontSize: 16 },
  };

  const variants = {
    primary: { background: T.orange, color: '#fff', boxShadow: `0 4px 14px ${T.orange}44` },
    teal: { background: T.teal, color: '#fff', boxShadow: `0 4px 14px ${T.teal}44` },
    gold: { background: T.gold, color: T.brown, boxShadow: `0 4px 14px ${T.gold}44` },
    red: { background: T.red, color: '#fff' },
    secondary: { background: '#F7F2ED', color: T.brownM, border: '1.5px solid #E8DDD5' },
    outline: { background: 'transparent', color: T.brownM, border: '1.5px solid #E8DDD5' },
    ghost: { background: 'transparent', color: T.brownM },
  };

  return { ...base, ...sizes[size], ...variants[variant], ...sx };
}

function addLift(target: HTMLElement, disabled: boolean) {
  if (!disabled) {
    target.style.transform = 'translateY(-1px)';
  }
}

function resetLift(target: HTMLElement) {
  target.style.transform = 'translateY(0)';
}

const Button = forwardRef<HTMLButtonElement, ButtonProps>(
  ({ className, variant = 'primary', size = 'md', disabled, style, ...props }, ref) => {
    const buttonStyle = getButtonStyles(variant, size, disabled, style);

    return (
      <button
        className={className}
        style={buttonStyle}
        ref={ref}
        disabled={disabled}
        onMouseEnter={(e) => addLift(e.currentTarget, !!disabled)}
        onMouseLeave={(e) => resetLift(e.currentTarget)}
        {...props}
      />
    );
  }
);

Button.displayName = 'Button';

export { Button };