import { cn } from "./utils";

function LoadingSpinner({ className, ...props }: React.ComponentProps<"div">) {
  return (
    <div
      role="status"
      aria-label="Lädt"
      className={cn("flex items-center justify-center", className)}
      {...props}
    >
      <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary" />
    </div>
  );
}

export { LoadingSpinner };
