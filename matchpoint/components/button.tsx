import { ButtonHTMLAttributes } from "react";
import clsx from "clsx";

interface ButtonProps extends ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: "primary" | "secondary" | "ghost";
}

export default function Button({ variant = "primary", className, ...props }: ButtonProps) {
  return (
    <button
      className={clsx(
        "px-4 py-2 rounded-lg font-semibold transition",
        {
          "bg-orange-500 text-white hover:bg-orange-600": variant === "primary",
          "bg-white text-darkBlue border border-darkBlue hover:bg-gray-100": variant === "secondary",
          "text-darkBlue hover:bg-gray-200": variant === "ghost",
        },
        className
      )}
      {...props}
    />
  );
}