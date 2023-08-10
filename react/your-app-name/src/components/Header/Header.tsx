import { FunctionComponent } from "react";
import classes from "./header.module.scss";
import { CartWidget } from "../CartWidget";
import { Link } from "react-router-dom";

export const Header: FunctionComponent = () => {
	let productsCount = 0;
	return (
		<header className={classes.header}>
			<div>
				<Link to="/">
					<img
						className={classes.logo}
						alt="shopping cart"></img>
				</Link>
			</div>
			<div>
				<CartWidget productsCount={productsCount} />
			</div>
		</header>
	);
};
