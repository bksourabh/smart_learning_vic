"use client";

import { useCallback, useEffect, useState } from "react";

/**
 * SSR-safe hook that syncs state with localStorage.
 *
 * During SSR / first render `initialValue` is used.
 * On mount the stored value (if any) is hydrated into state.
 * Every subsequent `setValue` call persists to localStorage.
 */
export function useLocalStorage<T>(
  key: string,
  initialValue: T
): [T, (value: T | ((prev: T) => T)) => void] {
  // Always start with the initial value (SSR-safe)
  const [storedValue, setStoredValue] = useState<T>(initialValue);

  // Hydrate from localStorage on mount
  useEffect(() => {
    try {
      const item = localStorage.getItem(key);
      if (item !== null) {
        setStoredValue(JSON.parse(item) as T);
      }
    } catch {
      // localStorage unavailable or corrupt data – keep initialValue
    }
  }, [key]);

  // Setter that also persists to localStorage
  const setValue = useCallback(
    (value: T | ((prev: T) => T)) => {
      setStoredValue((prev) => {
        const nextValue =
          value instanceof Function ? value(prev) : value;
        try {
          localStorage.setItem(key, JSON.stringify(nextValue));
        } catch {
          // localStorage unavailable
        }
        return nextValue;
      });
    },
    [key]
  );

  return [storedValue, setValue];
}
