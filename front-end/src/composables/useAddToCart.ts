import { firstValidationError } from "../services/account";
import { useCartStore } from "../stores/cart";
import { useToastStore } from "../stores/toast";

// Guests can add products to cart and checkout without creating an account.
export function useAddToCart() {
  const cartStore = useCartStore();
  const toast = useToastStore();

  async function ensureSignedIn(_guestMessage = ""): Promise<boolean> {
    return true;
  }

  async function addToCart<T extends { id: number; name: string; price: number }>(
    product: T,
    quantity = 1,
    guestMessage = "Sign in to add items to your cart."
  ): Promise<boolean> {
    if (!(await ensureSignedIn(guestMessage))) {
      return false;
    }

    try {
      await cartStore.addItem(product, quantity);
      toast.success(`${product.name} added to cart.`);
      return true;
    } catch (e) {
      toast.error(firstValidationError(e, "Could not add that item to your cart."));
      return false;
    }
  }

  return { addToCart, ensureSignedIn };
}
