import { create } from 'zustand';

interface ExampleStore {
  isVisible: boolean;
  toggleVisibility: () => void;
  setVisibility: (isVisible: boolean) => void;
}

export const useExampleStore = create<ExampleStore>((set) => ({
  isVisible: false,

  toggleVisibility: () =>
    set((state) => ({ isVisible: !state.isVisible })),

  setVisibility: (isVisible: boolean) => set({ isVisible }),
}));
