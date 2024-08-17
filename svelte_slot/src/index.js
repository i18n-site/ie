import { detach, mount_component, noop } from "svelte/internal";

// https://github.com/sveltejs/svelte/issues/2588#issuecomment-1134612872
export default (ele) => () => {
	let c;
	return {
		c: noop,
		// mount
		m: (target, anchor) => {
			mount_component(
				(c = new ele({
					target,
				})),
				target,
				anchor,
				null,
			);
		},
		// destroy
		d: (detaching) => {
			if (detaching) {
				detach(c);
			}
		},
		l: noop,
	};
};
