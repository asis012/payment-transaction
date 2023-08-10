import { FunctionComponent } from "react";
import classes from "./cartWidget.module.scss";
import { useNavigate } from "react-router-dom";
import shoppingCart from "../../assets/shopping-cart.svg"

interface Props {
	productsCount: number;
}

export const CartWidget: FunctionComponent<Props> = ({ productsCount }) => {
	const navigate = useNavigate();
	const navigateToCart = () => {
		// Use the navigate function to programmatically navigate to a different route
		navigate("/cart");
	};
	return (
		<button
			className={classes.container}
			onClick={navigateToCart}>
			<span className={classes.productsCount}>{productsCount}</span>
			<img
				src={shoppingCart}
				className={classes.shoppingCart}
				alt="Go to Cart"
			/>
		</button>
	);
};
